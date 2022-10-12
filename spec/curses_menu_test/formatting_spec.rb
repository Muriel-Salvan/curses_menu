describe CursesMenu do

  it 'displays a single string' do
    test_menu do |menu|
      menu.item 'Simple string'
    end
    assert_line 3, 'Simple string'
  end

  it 'displays a single string in UTF-8' do
    test_menu do |menu|
      menu.item 'Simple string - 単純な文字列'
    end
    # Ruby curses does not handle wide characters correctly in the inch method.
    # This test is pending a better support for UTF-8.
    # cf https://github.com/ruby/curses/issues/65
    # TODO: Uncomment when Ruby curses will be fixed.
    # assert_line 3, 'Simple string - 単純な文字列'
    assert_line 3, /^Simple string - .+$/
  end

  it 'displays a single string in a CursesRow' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new({ cell: { text: 'Simple string' } })
    end
    assert_line 3, 'Simple string'
  end

  it 'displays a different color' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Selected colored string',
            color_pair: CursesMenu::COLORS_GREEN
          }
        }
      )
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Non-selected colored string',
            color_pair: CursesMenu::COLORS_GREEN
          }
        }
      )
    end
    assert_colored_line 3, 'Selected colored string', :COLORS_MENU_ITEM_SELECTED
    assert_colored_line 4, 'Non-selected colored string', :COLORS_GREEN
  end

  it 'adds prefixes' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            begin_with: 'PRE'
          }
        }
      )
    end
    assert_line 3, 'PRESimple string'
  end

  it 'adds suffixes' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            end_with: 'POST'
          }
        }
      )
    end
    assert_line 3, 'Simple stringPOST'
  end

  it 'limits fixed-size strings that exceed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 5
          }
        }
      )
    end
    assert_line 3, 'Simpl'
  end

  it 'pads fixed-size strings that do not exceed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            pad: '*'
          }
        }
      )
    end
    assert_line 3, 'Simple string**'
  end

  it 'pads fixed-size strings that do not exceed size with multi-chars padding' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 20,
            pad: '12345'
          }
        }
      )
    end
    assert_line 3, 'Simple string1234512'
  end

  it 'does not pad fixed-size strings that exceed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 5,
            pad: '*'
          }
        }
      )
    end
    assert_line 3, 'Simpl'
  end

  it 'left-justifies fixed-size strings that do not exceed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            pad: '*',
            justify: :left
          }
        }
      )
    end
    assert_line 3, 'Simple string**'
  end

  it 'right-justifies fixed-size strings that do not exceed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            pad: '*',
            justify: :right
          }
        }
      )
    end
    assert_line 3, '**Simple string'
  end

  it 'never truncates prefixes when size exceeds fixed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            begin_with: 'PRE'
          }
        }
      )
    end
    assert_line 3, 'PRESimple strin'
  end

  it 'never truncates suffixes when size exceeds fixed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            end_with: 'POST'
          }
        }
      )
    end
    assert_line 3, 'Simple striPOST'
  end

  it 'never truncates prefixes and suffixes when size exceeds fixed size' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell: {
            text: 'Simple string',
            fixed_size: 15,
            begin_with: 'PRE',
            end_with: 'POST'
          }
        }
      )
    end
    assert_line 3, 'PRESimple sPOST'
  end

  it 'displays several cells' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell_1: { text: 'Cell 1' },
          cell_2: { text: 'Cell 2' },
          cell_3: { text: 'Cell 3' }
        }
      )
    end
    assert_line 3, 'Cell 1 Cell 2 Cell 3'
  end

  it 'displays several cells with a different separator' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell_1: { text: 'Cell 1' },
          cell_2: { text: 'Cell 2' },
          cell_3: { text: 'Cell 3' }
        },
        separator: 'SEP'
      )
    end
    assert_line 3, 'Cell 1SEPCell 2SEPCell 3'
  end

  it 'does not exceed line when several cells are too long' do
    nbr_visible_chars = Curses.stdscr.maxx
    nbr_chars_per_cell = (nbr_visible_chars / 3) + 1
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell_1: { text: '1' * nbr_chars_per_cell },
          cell_2: { text: '2' * nbr_chars_per_cell },
          cell_3: { text: '3' * nbr_chars_per_cell },
          cell_4: { text: '4' * nbr_chars_per_cell }
        }
      )
      menu.item 'Menu item 2'
    end
    assert_line 3, "#{'1' * nbr_chars_per_cell} #{'2' * nbr_chars_per_cell} #{'3' * (nbr_visible_chars - (2 * nbr_chars_per_cell) - 3)}"
    assert_line 4, 'Menu item 2'
  end

  it 'does not exceed line when several cells are too long due to separators' do
    nbr_visible_chars = Curses.stdscr.maxx
    nbr_chars_per_cell = (nbr_visible_chars / 3) + 1
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell_1: { text: '1' * nbr_chars_per_cell },
          cell_3: { text: '3' * nbr_chars_per_cell }
        },
        separator: '2' * nbr_chars_per_cell
      )
      menu.item 'Menu item 2'
    end
    assert_line 3, "#{'1' * nbr_chars_per_cell}#{'2' * nbr_chars_per_cell}#{'3' * (nbr_visible_chars - (2 * nbr_chars_per_cell) - 1)}"
    assert_line 4, 'Menu item 2'
  end

  it 'displays several cells with different properties' do
    test_menu do |menu|
      menu.item CursesMenu::CursesRow.new(
        {
          cell_1: {
            text: 'Cell 1',
            begin_with: 'PRE'
          },
          cell_2: {
            text: 'Cell 2',
            color_pair: CursesMenu::COLORS_GREEN,
            end_with: 'POST'
          },
          cell_3: {
            text: 'Cell 3',
            fixed_size: 10,
            pad: '*',
            justify: :right
          },
          cell_4: {
            text: 'Cell 4',
            fixed_size: 2
          },
          cell_5: {
            text: 'Cell 5',
            fixed_size: 10,
            pad: '='
          }
        }
      )
    end
    # TODO: Find a way to test colors
    assert_line 3, 'PRECell 1 Cell 2POST ****Cell 3 Ce Cell 5===='
  end

  it 'can reorder cells' do
    row = CursesMenu::CursesRow.new(
      {
        cell_1: { text: 'Cell 1' },
        cell_2: { text: 'Cell 2' },
        cell_3: { text: 'Cell 3' }
      }
    )
    row.cells_order(%i[cell_3 cell_2 cell_1])
    test_menu { |menu| menu.item row }
    assert_line 3, 'Cell 3 Cell 2 Cell 1'
  end

  it 'can reorder cells and ignore unknown ones' do
    row = CursesMenu::CursesRow.new(
      {
        cell_1: { text: 'Cell 1' },
        cell_2: { text: 'Cell 2' },
        cell_3: { text: 'Cell 3' }
      }
    )
    row.cells_order(%i[cell_4 cell_3 cell_5 cell_2 cell_1])
    test_menu { |menu| menu.item row }
    assert_line 3, 'Cell 3 Cell 2 Cell 1'
  end

  it 'can reorder cells and create unknown ones' do
    row = CursesMenu::CursesRow.new(
      {
        cell_1: { text: 'Cell 1' },
        cell_2: { text: 'Cell 2' },
        cell_3: { text: 'Cell 3' }
      }
    )
    row.cells_order(%i[cell_4 cell_3 cell_5 cell_2 cell_1], unknown_cells: 'Cell X')
    test_menu { |menu| menu.item row }
    assert_line 3, 'Cell X Cell 3 Cell X Cell 2 Cell 1'
  end

  it 'can reorder cells and create unknown ones with properties' do
    row = CursesMenu::CursesRow.new(
      {
        cell_1: { text: 'Cell 1' },
        cell_2: { text: 'Cell 2' },
        cell_3: { text: 'Cell 3' }
      }
    )
    row.cells_order(
      %i[cell_4 cell_3 cell_5 cell_2 cell_1],
      unknown_cells: {
        text: 'Cell X',
        begin_with: '{',
        end_with: '}'
      }
    )
    test_menu { |menu| menu.item row }
    assert_line 3, '{Cell X} Cell 3 {Cell X} Cell 2 Cell 1'
  end

  it 'can change cells properties' do
    row = CursesMenu::CursesRow.new(
      {
        cell_1: {
          text: 'Cell 1',
          begin_with: 'PRE',
          end_with: 'POST'
        },
        cell_2: {
          text: 'Cell 2'
        },
        cell_3: {
          text: 'Cell 3',
          fixed_size: 10,
          pad: '*'
        }
      }
    )
    row.change_cells(
      {
        cell_1: {
          begin_with: 'PRE2'
        },
        cell_2: {
          fixed_size: 2
        },
        cell_3: {
          text: 'Cell X',
          pad: '-='
        }
      }
    )
    test_menu { |menu| menu.item row }
    assert_line 3, 'PRE2Cell 1POST Ce Cell X-=-='
  end

end
