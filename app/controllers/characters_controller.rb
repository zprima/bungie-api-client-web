class CharactersController < ApplicationController
  before_action :authenticate

  def index
    @characters = DestinyProfile.for(current_user).characters

    @race_definitions = DestinyManifest.for(DestinyDefinition.race)
    @gender_definitions = DestinyManifest.for(DestinyDefinition.gender)
    @class_definitions = DestinyManifest.for(DestinyDefinition.xClass)
  end
end
