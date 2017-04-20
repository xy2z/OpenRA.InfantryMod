# InfantryMod

This mod is currently in BETA - please send some feedback if you're testing it.
[Get the map here](http://resource.openra.net/maps/20593/)

![Image](http://i.imgur.com/0mdgC2z.png)

## About
This is a mod for __maps__ in [OpenRA](http://www.openra.net): Red Alert.

Only infantry is available in this mod, along with a couple super weapons such as paradrops.

The goal is to capture and control as many oil derricks as possible, until a team reaches the winning points.

This currently works on OpenRA version **20161019**.

## Maps
[See a list of all InfantryMod maps on the resource center](http://resource.openra.net/maps/?category=Infantry&sort_by=latest&with_problems=show&players=).

## Rules
- No MCV. Only barracks.
- All infantry is available. Default price.
- Barracks health is set to 8000 (up from 600)
- Oil derricks health is 20000 (up from 1000)
- Super Weapons: parabombs, paradrops and spy plane.
- Get points by capturing and controlling oil derricks. (see Points below)
- Capturing an oil derricks gives $50 and then $25 every few seconds.

## Make your own map
This mod is very simple to add to your own map.
1. Create a map with oil derricks
1. Set the `Categories` to `Infantry` in `map.yaml`.
1. Add this code to the bottom of your `map.yaml` file
```yaml
Rules: infantry-rules.yaml
```
1. Zip your .oramap including the `infantry-rules.yaml` and `infantrymod.lua`
1. Play

Doesn't work? [Get help here](https://github.com/xy2z/OpenRA.InfantryMod/wiki/Troubleshooting)

__Remember to:__
- Add your map to the [Resource center](http://resource.openra.net/upload/map/).
- Check in on new releases of the mod, and update your map with fixes and new features.

## Points
To win you need to get these points:
- 2 players: 30
- 4 players: 35
- 6 players: 40
- 8 players: 45
- 10 players or more: 50

## Contribute
Feel free to create a pull request.

## Bugs & Features
Found a bug? Got an idea for a feature? [Create an issue here](https://github.com/xy2z/OpenRA.InfantryMod/issues/new).
