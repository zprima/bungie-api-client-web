class DestinyInventoryBucket
  
  BUCKETS = {
    'kineticWeapons' => 1498876634,
    'energyWeapons' => 2465295065,
    'powerWeapons' => 953998645,
    'ghost' => 4023194814,
    'helmet' => 3448274439,
    'gauntlets' => 3551918588,
    'chestArmor' => 14239492,
    'legArmor' => 20886954,
    'classArmor' => 1585787867,
    'vehicle' => 2025709351,
    'ships' => 284967655,
    'emblems' => 4274335291,
    'emotes' => 3054419239,
    'lostItems' => 215593132,
    'general' => 138197802,
    'consumables' => 1469714392,
    'shaders' => 2973005342,
    'specialOrders' => 1367666825,
    'upgradePoint' => 2689798304,
    'glimmer' => 2689798308,
    'legendaryShards' => 2689798309,
    'strangeCoin' => 2689798305,
    'silver' => 2689798310,
    'brightDust' => 2689798311,
    'messages' => 3161908920,
    'subclass' => 3284755031,
    'modifications' => 3313201758,
    'materials' => 3865314626,
    'clanBanners' => 4292445962,
    'engrams' => 375726501,
    'pursuits' => 1345459588
  }

  self::BUCKETS.each do |k,v|
    define_singleton_method k.camelize(:lower) do
      v
    end
  end
end