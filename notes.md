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
- 4 is hydrated
- 5 is rotten
- 6 is harvestable

# Harvestable growth
If a tile has a harvestable planted then each frame, the tile has a 50% chance to decrease it's growth timer. When the timer reaches 0 the plant will advance to the next stage in the growth sequence.

## Carrots
Carrots take 12 hours to advance stage and 10 to dry

# Data save
## Save map
To save the game map, all used tiles are set in the PICO-8 map and then stored to the cart.
The various layers are stored one above the other in the map editor and are then re layered when loading the map.

## Save tile data
The memory address 0x4300 (general use) is used to store data about the tiles. in particular, each tile stores:
- grow_stage: the current growth stage.
- grow_timer: the current timer value until next stage.
- dry_timer: the current hydration level of the plant.
grow_timer and dry_timer will be multiplied by 100 when stored in order to fit in a single byte of memory.

## Save cart data
State data and other information will be store in the cart-data structure as described bellow:

0. Last save time - Year
1. Last save time - Month
2. Last save time - Day
3. Last save time - Hour
4. Last save time - Minute
5. Last elapsed time in minutes
6. Last tool
7. Last player x
8. Last player y
9. Inventory - Carrots

# Time
Time is managed at the minute level to avoid overflowing numbers.
The max tracked time between sessions is 1 week or 10080 minutes. Any time above this threshold will be ignored.