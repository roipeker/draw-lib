# Draw lib (for StarlingFW)

Draw tries to mimic [AS3 Graphics API](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html) but is powered by [Starling](https://gamua.com/starling/). Was heavily ported from the Graphics implementation in PixiJS.
And, although I do not recommend it for production use, the code wasn't tested enough and is unoptimized, it seems to work fine for simple vector shapes in my testings.

## Getting Started

The code in this repo contains a *IntellijIdea* project with 2 projects modules:
* draw_demos 
* draw_lib

You can get a precompiled binary for Draw inside _/draw_lib/bin/draw_lib.swc_, but the Intellij project uses Build Configurations dependencies to run the samples.

### Prerequisites

Intellij and some version of [AdobeSDK](https://www.adobe.com/devnet/air/air-sdk-download.html) compatible with Starling v2.5.1

### API and some demos.

Considere the API very similar to the AS3 Graphics one. 

I didn't have the time to write documentation (or code comments), but 90% of the code was ported from PixiJS, so check their [docs](http://pixijs.download/dev/docs/PIXI.Graphics.html).


## Contributing

Please, that's the point of why I setup this repo :)

## Authors

* **Rodrigo Lopez** - *Initial work* - [roipeker](https://roipeker.com/https://github.com/roipeker)

## Acknowledgments

* [Starling](https://forum.starling-framework.org/)
* [PixiJS](https://www.pixijs.com/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
