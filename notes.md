# Sprite Flags
the first 4 flags are reserved to layer definition as follows:
- 0 ground: grass and tilled dirt
- 1 water: waterways
- 2 harvestable: seeds and grown plants
- 3 structures: fences and intractable items

The following 4 flags can be used for different goals based on the layers.

## Ground layer flags
Flags 4 to 7 indicate if the current tile has dirt on it's borders in the order top, right, bottom, left.

## Harvest layer flags
The flags indicate the status of the harvestable
- 4 is hidrated
- 5 is rotten

## Save map
To save the game map, all used tiles are set in the PICO-8 map and then stored to the cart.
The various layers are stored one above the other in the map editor and are then re layered when loading the map.