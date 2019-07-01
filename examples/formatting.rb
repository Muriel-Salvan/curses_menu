require 'curses_menu'

dynamic_row_1 = CursesMenu::CursesRow.new(
  first_cell: { text: 'Select to' },
  second_cell: {
    text: 'change the',
    color_pair: CursesMenu::COLORS_GREEN
  },
  third_cell: {
    text: 'cells order',
    color_pair: CursesMenu::COLORS_RED
  }
)
dynamic_row_2 = CursesMenu::CursesRow.new(
  first_cell: { text: 'Select to change' },
  second_cell: {
    text: 'the cells properties',
    color_pair: CursesMenu::COLORS_GREEN,
    fixed_size: 40
  }
)
CursesMenu.new 'Extended formatting available too!' do |menu|
  menu.item CursesMenu::CursesRow.new(
    default_cell: {
      text: 'Simple color change - GREEN!',
      color_pair: CursesMenu::COLORS_GREEN
    }
  )
  menu.item CursesMenu::CursesRow.new(
    green_cell: {
      text: 'Several cells ',
      color_pair: CursesMenu::COLORS_GREEN
    },
    red_cell: {
      text: 'with different ',
      color_pair: CursesMenu::COLORS_RED
    },
    blue_cell: {
      text: 'formatting',
      color_pair: CursesMenu::COLORS_BLUE
    }
  )
  menu.item CursesMenu::CursesRow.new(
    default_cell: {
      text: 'Use prefixes and suffixes',
      begin_with: '[ ',
      end_with: ' ]'
    }
  )
  menu.item CursesMenu::CursesRow.new(
    first_cell: {
      text: 'This will have a fixed size!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
      begin_with: '[ ',
      end_with: ' ]',
      fixed_size: 40
    },
    second_cell: {
      text: 'And other cells will be aligned',
      color_pair: CursesMenu::COLORS_GREEN
    }
  )
  menu.item CursesMenu::CursesRow.new(
    first_cell: {
      text: 'Pretty nice',
      fixed_size: 40
    },
    second_cell: {
      text: 'for alignment',
      color_pair: CursesMenu::COLORS_GREEN
    }
  )
  menu.item CursesMenu::CursesRow.new(
    first_cell: {
      text: 'And you can justify',
      justify: :right,
      fixed_size: 40
    },
    second_cell: {
      text: 'your text when size is fixed!',
      justify: :left,
      color_pair: CursesMenu::COLORS_GREEN
    }
  )
  menu.item CursesMenu::CursesRow.new(
    first_cell: {
      text: 'You can even',
      justify: :right,
      fixed_size: 40,
      pad: '_-'
    },
    second_cell: {
      text: 'pad it!',
      justify: :left,
      color_pair: CursesMenu::COLORS_GREEN,
      fixed_size: 40,
      pad: '*'
    }
  )
  menu.item CursesMenu::CursesRow.new(
    {
      first_cell: { text: 'Use a' },
      second_cell: {
        text: 'different separator',
        color_pair: CursesMenu::COLORS_GREEN
      },
      third_cell: { text: 'between cells' }
    },
    separator: '|'
  )
  menu.item dynamic_row_1 do
    dynamic_row_1.cells_order([:first_cell, :second_cell, :third_cell].sort_by { rand })
    :menu_refresh
  end
  menu.item dynamic_row_2 do
    dynamic_row_2.change_cells(
      first_cell: {
        color_pair: [CursesMenu::COLORS_GREEN, CursesMenu::COLORS_RED, CursesMenu::COLORS_BLUE].sample
      },
      second_cell: {
        color_pair: [CursesMenu::COLORS_GREEN, CursesMenu::COLORS_RED, CursesMenu::COLORS_BLUE].sample,
        pad: ['*', ' ', '|', '='].sample
      }
    )
    :menu_refresh
  end
  menu.item 'Quit' do
    puts 'Quitting...'
    :menu_exit
  end
end
