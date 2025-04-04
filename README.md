# Radial Menu Component for Godot 4

![Godot 4 Compatible](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine&style=flat-square)  
![MIT License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

A Godot 4 addon that provides customizable radial menu components for your projects. This addon simplifies the creation of radial menus, making it easy to implement intuitive and visually appealing UI elements.

## Features

- Fully customizable radial menus.
- Support for dynamic menu items.
- Easy integration into existing projects.
- Adjustable radius, angles, and item spacing.
- Works seamlessly with Godot 4's scene system.

## Installation

1. Download or clone this repository into your Godot project's `addons/` folder.
2. Enable the addon in your project settings under `Project > Project Settings > Plugins`.
3. You can now use the RadialMenu Nodes.

## Usage

1. Add the `RadialMenu2D` or `RadialMenu3DFlat` node to your scene.
2. Create an array of `RadialMenuItem` resources, each representing a menu item. Configure their properties such as `option_name`, `description`, `image`, and `callback_name`.
3. Assign the array of `RadialMenuItem` resources to the `items` property of the `RadialMenu` node.
4. Customize the appearance and behavior of the radial menu by creating and assigning a `RadialMenuSettings` resource to the `settings` property of the `RadialMenu` node.
5. Both the `items` and `settings` properties are exposed in the Godot inspector, allowing you to edit them directly in the editor or via code.
6. Use the signals `selected`, `selection_changed`, and `canceled` to handle user interactions with the menu.

For detailed examples, check the `examples/` folder in this repository.

## Compatibility

This addon is designed for Godot 4.x. It may not work with earlier versions of Godot.

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve this addon.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE.md) file for details.

## Acknowledgments

A big thank you to the Twitch community for their support, feedback, and encouragement during the development of this project.  
![Twitch Profile](https://static-cdn.jtvnw.net/jtv_user_pictures/your-profile-image.png)  
Special thanks to the Godot community for their support and inspiration.

The 2D part of the `RadialMenu2D.gd` class is based on the work of [diklor](https://github.com/diklor/advanced_radial_menu).

Thanks to Andrea Di Bartolo (SirAeron), a 3D modeller, for providing assets for the example scene. Check out his portfolio at [ArtStation](https://www.artstation.com/andreadbx).

Some of the food item assets are from the [Food Kit](https://kenney.nl/assets/food-kit) by [Kenney](https://kenney.nl/).  
![Kenney Logo](https://kenney.nl/data/images/kenney-logo.png)

This plugin was developed for the [Radial Menu Game Jam #1](https://itch.io/jam/radial-menu-game-jam-1) hosted on itch.io.  
![Radial Menu Game Jam Logo](https://img.itch.zone/aW1hZ2UvMTg4NzQyLzEwOTYyNjkucG5n/original/2b3FJ9.png)
