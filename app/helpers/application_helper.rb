module ApplicationHelper
  def bungie_url(path)
    URI("https://www.bungie.net/#{path}").to_s
  end

  def definition_for(collection, hash)
    collection.find_by(definition_hash: hash).definition
  end
end
