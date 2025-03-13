# Catalyst Device:
- Used to transmute select MagiClay. User can pick result from a menu.
- Emits a signal which must be connected to MagiClay's `set_element` method.
- The options can enabled/disabled by designer using `elements` property.

# Reset
If pressed by player, will revert all MagiClay to their original element. These should be added to the appropriate `Chunk` node.