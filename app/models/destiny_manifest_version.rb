class DestinyManifestVersion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :manifest_version, type: String

  after_update :flush_name_cache

  def flush_name_cache
    Rails.cache.delete("manifest_#{self.manifest_version}")
  end
end