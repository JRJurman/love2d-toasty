# Toasty

Submission for [Games for Blind Gamers 5](https://itch.io/jam/games-for-blind-gamers-5)

Homepage - https://jrjurman.itch.io/toasty

## Resources

Game Designed by Jesse Jurman. Play testing and design help from Eva Jurman, Tina Howard, and Katie Walker
Music created using GarageBand by Jesse Jurman and Eva Jurman.
Sounds by Jesse Jurman.
Art created using Affinity by Eva Jurman.

Inspired by Dogpile, Balatro, Flip 7

- Color Palette: https://lospec.com/palette-list/apollo
- Screen Reader Template: https://github.com/JRJurman/love2d-a11y-template

## Attributions

Font:
Cherry Bomb One -- https://github.com/satsuyako/CherryBomb -- SIL OPEN FONT LICENSE Version 1.1

## Development

This project contains the source for the desktop, web, android, and iOS builds of the game. They are all modified slightly to enable screen reader support.

The web build is based off of [love2d-a11y-template](https://github.com/JRJurman/love2d-a11y-template), which updates a dynamic text element to interact with screen readers.

The Desktop, Android, and iOS projects rely on [SRAL](https://github.com/m1maker/SRAL), a C++ library which interfaces with assistive devices and technologies.

### Web Build

For the web build, you'll need to do the following:

```sh
npm ci # install dependencies
./build.sh # make the web assets locally
```

To run the game, you can run `./start-web.sh`.

### Android Build

```sh
./build.sh
./build-android.sh
```

### iOS Build

_To be added_
