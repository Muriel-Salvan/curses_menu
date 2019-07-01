# curses_menu

Ruby API to create terminal-based menus, using [curses][link-curses].

* Easy navigation using arrows, page up/down, home, end, enter and escape keys.
* Several actions per menu item.
* Scrolling support.
* Extensive formatting options with colors, alignments, decorations...
* Easy support for sub-menus.
* Automatic key presses for autmating tasks in the menu.
* Ruby-like API.

## Install

Via gem

``` bash
$ gem install curses_menu
```

Via a Gemfile

``` ruby
$ gem 'curses_menu'
```

## Usage

``` ruby
require 'curses_menu'

CursesMenu.new 'My awesome new menu!' do |menu|
  menu.item 'How\'s life?' do
    puts 'Couldn\'t be easier'
    :menu_exit
  end
end
```

Check the [examples][link-examples] folder for more examples.

## Change log

Please see [CHANGELOG](CHANGELOG.md) for more information on what has changed recently.

## Testing

Automated tests are done using rspec.

Do execute them, first install development dependencies:

```bash
bundle install
```

Then execute rspec

```bash
bundle exec rspec
```

## Contributing

Any contribution is welcome:
* Fork the github project and create pull requests.
* Report bugs by creating tickets.
* Suggest improvements and new features by creating tickets.

## Credits

- [Muriel Salvan][link-author]

## License

The BSD License. Please see [License File](LICENSE.md) for more information.

[link-curses]: https://rubygems.org/gems/curses/versions/1.2.4
[link-examples]: ./examples
