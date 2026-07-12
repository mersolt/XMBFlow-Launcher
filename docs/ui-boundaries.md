# Legacy UI boundaries

## Purpose

This map identifies what a future XMB interface may replace and what it must
continue to accept from RetroFlow. It does not define a new UI or change any
runtime behaviour.

The current interface is not a separate component. It shares state with the
scanner, cache, settings, collections, artwork, and launch code in
`src/index.lua`. For that reason, the first XMB prototype should be added
behind a small presentation boundary instead of moving large blocks of legacy
code at once.

## Compatibility contract

The XMB interface may change how the library is presented. It must preserve
the meaning and lifecycle of these values until a separately tested migration
replaces them:

| Value | Current meaning | Compatibility rule |
| --- | --- | --- |
| `showMenu` | Active screen: `0` is the library and `1` through `28` select legacy menus. | Do not reuse existing numbers for different actions. |
| `showCat` | Active library category. Regular systems, favourites, recents, search, and collections all use this value. | Resolve data through existing category helpers; do not renumber categories. |
| `showView` | Current cover/list presentation mode. | Keep saved `View=` settings readable even if a new renderer eventually maps them differently. |
| `p` | One-based selected item position in the active category; it can be `0` for an empty category. | Clamp through existing boundary logic and never assume the category is non-empty. |
| `master_index` | Anchor used by cover/list scrolling. | Update it with `p` using the same navigation rules until scrolling is replaced as one unit. |
| `menuX`, `menuY` | Cursor positions within legacy menus. | Keep menu transitions and their return positions intact. |
| `curTotal` | Number of visible items in the active category. | Derive it from the active legacy table, including the special favourites view. |
| `pad`, `oldpad` | Current and previous controller state. | Preserve edge-triggered button handling so one press does not cause repeated actions. |

## Data supplied to the UI

`xCatLookup(showCat)` is the main bridge from category state to a game table.
Search, favourites, recents, and collections have special handling around this
lookup. A displayed game record can contain fields used outside rendering,
including:

- title and identity fields such as `apptitle`, `titleid`, `filename`, and
  `path`;
- routing fields such as `app_type`, core/driver overrides, and cartridge
  state;
- presentation fields such as `icon_path`, background paths, and lazily loaded
  image handles;
- library metadata such as favourite, hidden, collection, and recently played
  state.

The UI may read these records and request existing actions. It must not rename
fields, rewrite tables, or create a second library model during the first XMB
prototype.

## Rendering boundary

The legacy presentation is concentrated in these landmarks in
`src/index.lua`:

- render-asset and 3D cover-model loading near line 2589;
- shared navigation state near line 3023;
- cover measurement and draw helpers near line 12474;
- category and selected-game drawing near line 13685;
- the main frame loop near line 14353;
- per-screen rendering from the `MENU 0` block near line 15048 through the
  `END OF MENUS` marker near line 21508;
- input and actions beginning near line 21615;
- bounds correction and frame presentation near the end of the loop.

Line numbers are landmarks, not permanent APIs. The nearby
`LEGACY UI BOUNDARY` comments are the durable search terms.

## Current frame sequence

Each frame broadly does the following:

1. Update queued work and read controller/analog input.
2. Poll optional cartridge state and update idle cover work.
3. Process keyboard state used by search, rename, and collections.
4. Draw the shared background and the active library/menu screen.
5. Finish drawing, then process analog, button, and touch actions.
6. Correct selection bounds, wait for vertical blank, show the frame, and save
   the current controller state as `oldpad`.

The ordering matters. In particular, the current code draws before most button
actions, and uses `oldpad` to detect a new press. A later refactor must preserve
that timing until it can be tested on the Vita runtime.

## Actions that must remain behind existing helpers

An XMB item may expose an action, but it should call the existing operation
instead of duplicating it:

- game launch and its availability checks;
- favourite, hidden, recent, and collection updates;
- search and rename keyboard flows;
- artwork loading/downloading;
- rescan and cache rebuild;
- settings persistence;
- recovery operations.

Launch, scan, cache, installation, reboot, and delete functions are not part of
the presentation layer. UI work must not move, broaden, or call them earlier.

## Safest implementation seam

The first functional XMB change should be an opt-in renderer that receives the
active category table, selected position, and read-only presentation settings.
It should draw only; existing input and actions should remain in control. Keep
the legacy renderer as the default and fallback until the new renderer can be
packaged and tested. Do not add AutoBoot, Vita installation, or new file
operations as part of that work.
