describe CursesMenu do

  it 'actions the default selection when pressed enter' do
    actioned = false
    test_menu(keys: [CursesMenu::KEY_ENTER]) do |menu|
      menu.item 'Menu item' do
        actioned = true
      end
    end
    expect(actioned).to eq(true)
  end

  it 'actions the default selection when pressed enter on the correct item' do
    action = nil
    test_menu(keys: [Curses::KEY_DOWN, Curses::KEY_DOWN, CursesMenu::KEY_ENTER]) do |menu|
      menu.item 'Menu item 1' do
        action = 1
      end
      menu.item 'Menu item 2' do
        action = 2
      end
      menu.item 'Menu item 3' do
        action = 3
      end
      menu.item 'Menu item 4' do
        action = 4
      end
    end
    expect(action).to eq(3)
  end

  it 'actions other actions' do
    action = nil
    test_menu(keys: ['a']) do |menu|
      menu.item 'Menu item', actions: {
        'a' => {
          name: 'Action A',
          execute: proc { action = 'a' }
        },
        'b' => {
          name: 'Action B',
          execute: proc { action = 'b' }
        }
      }
    end
    expect(action).to eq('a')
  end

  it 'actions several actions' do
    actions = []
    test_menu(keys: ['a', 'b', 'a']) do |menu|
      menu.item 'Menu item', actions: {
        'a' => {
          name: 'Action A',
          execute: proc { actions << 'a' }
        },
        'b' => {
          name: 'Action B',
          execute: proc { actions << 'b' }
        }
      }
    end
    expect(actions).to eq(%w[a b a])
  end

  it 'actions several actions including the default one' do
    actions = []
    test_menu(keys: ['a', 'b', CursesMenu::KEY_ENTER, 'a']) do |menu|
      menu.item('Menu item', actions: {
        'a' => {
          name: 'Action A',
          execute: proc { actions << 'a' }
        },
        'b' => {
          name: 'Action B',
          execute: proc { actions << 'b' }
        }
      }) do
        actions << 'ENTER'
      end
    end
    expect(actions).to eq(%w[a b ENTER a])
  end

  it 'actions nothing if action does not exist' do
    actions = []
    test_menu(keys: ['a', 'b', 'c', 'a']) do |menu|
      menu.item('Menu item', actions: {
        'a' => {
          name: 'Action A',
          execute: proc { actions << 'a' }
        },
        'b' => {
          name: 'Action B',
          execute: proc { actions << 'b' }
        }
      }) do
        actions << 'ENTER'
      end
    end
    expect(actions).to eq(%w[a b a])
  end

  it 'exits when action returns :menu_exit' do
    quit = false
    test_menu(keys: [CursesMenu::KEY_ENTER], auto_exit: false) do |menu|
      menu.item 'Menu item quit' do
        quit = true
        :menu_exit
      end
    end
    expect(quit).to eq(true)
  end

  it 'navigates in sub-menus' do
    actions = []
    test_menu(keys: [
      # Enter sub-menu 1
      CursesMenu::KEY_ENTER,
      # Action sub-menu second item
      Curses::KEY_DOWN,
      CursesMenu::KEY_ENTER,
      # Back to first menu
      CursesMenu::KEY_ESCAPE,
      # Enter sub-menu 2
      Curses::KEY_DOWN,
      CursesMenu::KEY_ENTER,
      # Action sub-menu item
      CursesMenu::KEY_ENTER,
      # Exit sub-menu
      Curses::KEY_DOWN,
      CursesMenu::KEY_ENTER
    ]) do |menu, key_presses|
      menu.item 'Sub-menu 1' do
        CursesMenu.new('Sub-menu 1 title', key_presses: key_presses) do |sub_menu|
          sub_menu.item 'Sub-menu item 1'
          sub_menu.item 'Sub-menu item 2' do
            actions << 'a'
          end
        end
      end
      menu.item 'Sub-menu 2' do
        CursesMenu.new('Sub-menu 2 title', key_presses: key_presses) do |sub_menu|
          sub_menu.item 'Sub-menu item 1' do
            actions << 'b'
          end
          sub_menu.item 'Sub-menu item 2' do
            :menu_exit
          end
        end
      end
    end
    expect(actions).to eq(%w[a b])
  end

  it 'exits only the sub-menu when action returns :menu_exit in a sub-menu' do
    actions = []
    test_menu(keys: [CursesMenu::KEY_ENTER, CursesMenu::KEY_ENTER, Curses::KEY_DOWN, CursesMenu::KEY_ENTER]) do |menu, key_presses|
      menu.item 'Sub-menu' do
        CursesMenu.new('Sub-menu title', key_presses: key_presses) do |sub_menu|
          sub_menu.item 'Sub-menu item quit' do
            actions << 'a'
            :menu_exit
          end
        end
      end
      menu.item 'Menu item 2' do
        actions << 'b'
      end
    end
    expect(actions).to eq(%w[a b])
  end

  it 'exits only the sub-menu when Escape key is used' do
    actions = []
    test_menu(keys: [CursesMenu::KEY_ENTER, CursesMenu::KEY_ESCAPE, Curses::KEY_DOWN, CursesMenu::KEY_ENTER]) do |menu, key_presses|
      menu.item 'Sub-menu' do
        CursesMenu.new('Sub-menu title', key_presses: key_presses) do |sub_menu|
          sub_menu.item 'Sub-menu item quit' do
            actions << 'a'
            :menu_exit
          end
        end
      end
      menu.item 'Menu item 2' do
        actions << 'b'
      end
    end
    expect(actions).to eq(%w[b])
  end

  it 'does not refresh menu items normally' do
    idx = 0
    test_menu(keys: [CursesMenu::KEY_ENTER, CursesMenu::KEY_ENTER]) do |menu|
      menu.item "Menu item #{idx}" do
        idx += 1
      end
    end
    assert_line 3, 'Menu item 0'
  end

  it 'refreshes menu items when action returns :menu_refresh' do
    idx = 0
    test_menu(keys: [CursesMenu::KEY_ENTER, CursesMenu::KEY_ENTER]) do |menu|
      menu.item "Menu item #{idx}" do
        idx += 1
        :menu_refresh
      end
    end
    assert_line 3, 'Menu item 2'
  end

end
