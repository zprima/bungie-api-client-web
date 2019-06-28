class DestinyManifest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :definition_name, type: String
  field :definition_hash, type: String
  field :definition, type: Hash

  def self.for(definition_name)
    cache_key = "manifest_#{DestinyManifestVersion.last.manifest_version}"

    Rails.cache.fetch("#{cache_key}/#{definition_name}" , expires: 1.day) do
      where(definition_name: definition_name).to_a
    end
  end

  def self.get_manifest
    latest_manifest_info = BungieApiService.get_destiny_manifest()["Response"]
    version = latest_manifest_info["version"]

    dmv = DestinyManifestVersion.last
    if dmv.nil?
      dmv = DestinyManifestVersion.new(manifest_version: version)
      dmv.save
      store_manifest(latest_manifest_info)
    elsif dmv.manifest_version != version
      dmv.manifest_version = version
      dmv.save
      store_manifest(latest_manifest_info)
    end
  end

  def self.get_manifest_from_file
    DestinyManifestVersion.last || DestinyManifestVersion.new(manifest_version: '0').save

    store_manifest(nil)
  end

  private

  def self.store_manifest(manifest_info)
    data = 
      if manifest_info.present?
        path = manifest_info["jsonWorldContentPaths"]["en"]
        url = "https://www.bungie.net#{path}"
        response = HTTParty.get(url)
        JSON.parse(response.body)
      else
        file = File.read(Rails.root.join('tmp', 'response.json'))
        JSON.parse(file)
      end

    # clear
    DestinyManifest.delete_all

    # save
    records = []
    data.keys.each do |definition_name|
      # clean up invalid keys
      data[definition_name].each do |key, definition|
        filtered_definition = definition.select do |k, v|
          !k.include?('.')
        end

        records << {
          definition_name: definition_name,
          definition_hash: key,
          definition: filtered_definition
        }
      end
    end
    DestinyManifest.create(records)

    true
  end
end