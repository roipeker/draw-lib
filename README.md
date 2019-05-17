# draw-lib

Draw tries to mimic [AS3 Graphics API](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html) but is powered by [Starling](https://gamua.com/starling/). Was heavily ported from the Graphics implementation in PixiJS.
And, although I do not recommend it for production use, the code wasn't tested enough and is unoptimized, it seems to work fine for simple vector shapes in my testings.

-------------

#### Donation
Support **draw-lib** via [Paypal](https://www.paypal.me/roipeker/)

[![Donate via PayPal](https://cdn.rawgit.com/twolfson/paypal-github-button/1.0.0/dist/button.svg)](https://www.paypal.me/roipeker/)



##### IDE Software provided by JetBrains
[![Jetbrains](https://raw.githubusercontent.com/tuarua/WebViewANE/master/screenshots/jetbrains.png)](https://www.jetbrains.com)

-------------


## Getting Started

The code in this repo contains a *IntellijIdea* project with 2 projects modules:
* draw_demos 
* draw_lib

You can get a precompiled binary for Draw inside [_/draw_lib/bin-release/draw_lib.swc_](https://github.com/roipeker/draw-lib/tree/master/draw_lib/bin-release/draw_lib.swc), but the Intellij project uses Build Configurations dependencies to run the samples.

### Prerequisites

Intellij and some version of [AdobeSDK](https://www.adobe.com/devnet/air/air-sdk-download.html) compatible with Starling v2.5.1

### API and demos.

Considere the API very similar to the AS3 Graphics one. 

I didn't have the time to write documentation (or code comments), but 90% of the code was ported from PixiJS, so check their [docs](http://pixijs.download/dev/docs/PIXI.Graphics.html).

## demos screenshots

![demo 1](../media/images/demo1.png?raw=true)
![demo 2](../media/images/demo2.png?raw=true)
![demo 3](../media/images/demo3.gif?raw=true)
![demo 4](../media/images/demo4.gif?raw=true)
![demo 5](../media/images/demo5.gif?raw=true)
![demo 7](../media/images/demo7.png?raw=true)
![demo 8](../media/images/demo8.png?raw=true)
![demo 9](../media/images/demo9.gif?raw=true)
![demo 10](../media/images/demo10.gif?raw=true)
![demo 11](../media/images/demo11.png?raw=true)


## Contributing

That's why I setup this repo! So, use pull request. 

You can also [buy me a coffee](https://www.paypal.me/roipeker/).


## Authors

* **Rodrigo Lopez** - *Initial work* - [roipeker](https://roipeker.com/https://github.com/roipeker)

## Acknowledgments

* [Starling](https://forum.starling-framework.org/)
* [PixiJS](https://www.pixijs.com/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
