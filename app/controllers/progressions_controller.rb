class ProgressionsController < ApplicationController
  def index
    @bucket = DestinyInventoryBucket.pursuits
    @profile = DestinyProfile.for(current_user)

    @item_components = @profile.item_components
    @character_uninstanced_item_components = @profile.character_uninstanced_item_components[current_character_id]

    @inventory_item_definitions = DestinyManifest.for(DestinyDefinition.inventoryItem)
    @objective_definitions = DestinyManifest.for(DestinyDefinition.objective)

    @local_item_defs = {}
    @local_obj_defs = {}

    # @milestones = profile.character_progressions[current_character_id]['milestones']
    # @milestoneDefs = DestinyManifest.for(DestinyDefinition.milestone)

    build_pursuits
    build_milestones
  end

  private

  def build_milestones
  end

  def get_item_def(item_hash)
    @inventory_item_definitions.find_by(definition_hash: item_hash).definition
  end

  def get_objective(obj_hash)
    @objective_definitions.find_by(definition_hash: obj_hash).definition
  end

  def get_pursuits
    @profile.character_inventories[current_character_id]['items'].select{|x| x['bucketHash'] == @bucket}
  end

  def build_pursuits
    _pursuits = get_pursuits

    @pursuits = _pursuits.map do |pursuit|
      item_def = get_item_def(pursuit['itemHash'])

      progress_completed = -1

      objectives = []
      if item_def['objectives']
        objectives =
              if pursuit['itemInstanceId'] && @item_components['objectives']['data'][pursuit['itemInstanceId']]
                @item_components['objectives']['data'][pursuit['itemInstanceId']]['objectives']
              elsif @character_uninstanced_item_components
                @character_uninstanced_item_components['objectives']['data'][pursuit['itemHash'].to_s]["objectives"]
              else
                []
              end

        sum_objective_progress = 0
        objectives = objectives.map do |o|
          obj_def = get_objective(o['objectiveHash'])

          objective_progress = (100 * o['progress']) / o['completionValue']
          sum_objective_progress += objective_progress

          {
            'objective' => o,
            'objective_def' => obj_def,
            'objective_progress' => objective_progress
          }
        end

        progress_completed = sum_objective_progress / objectives.size
      end

      pursuit_expires_in = 0
      if pursuit['expirationDate']
        dt = pursuit['expirationDate'].to_datetime.in_time_zone('Europe/Ljubljana')
        total_seconds = dt - Time.now.in_time_zone('Europe/Ljubljana')
        # minutes = ((total_seconds / 60) % 60).round
        # hours = (total_seconds / (60 * 60)).round
        pursuit_expires_in = total_seconds
      end

      {
        'pursuit' => pursuit,
        'has_expiration' => pursuit['expirationDate'].present?,
        'expires_in' => pursuit_expires_in,
        'expired' =>  pursuit_expires_in.negative? ? 1 : 0,
        'item_def' => item_def,
        'objectives' => objectives,
        'progress_completed' => progress_completed
      }
    end.sort_by{|x| [-x['expired'], -x['expires_in'], -x['progress_completed']] }
  end
end
