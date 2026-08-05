# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [0.3.1] - 2026-08-05

### Fixed

- Fixed a memory leak in header/footer rendering caused by unfreed `strings.repeat` allocations

<table>
  <thead>
    <tr>
      <td></td>
      <th>0.3.0</th>
      <th>0.3.1</th>
    </tr>
  </thead>
  
  <tbody>
    <tr>
      <th>Maniac mode (actual shader rendering work)</th>
      <td>
        <img width="640" height="480" alt="usage_no_bum_aurora" src="https://github.com/user-attachments/assets/25f38adf-e37e-484a-b3f0-d1c9ee27f8fd" />        
      </td>
      <td>
        <img width="640" height="480" alt="fixed_no_bum_aurora" src="https://github.com/user-attachments/assets/33f4b42b-29bb-435f-a026-e1f30768f708" />
      </td>
    </tr>
    <tr>
      <th>Bum mode (no render work)</th>
      <td>
        <img width="640" height="480" alt="usage_bum_aurora" src="https://github.com/user-attachments/assets/c3f4cd37-3567-42df-bbd3-84dfd13a1874" />
      </td>
      <td>
        <img width="640" height="480" alt="fixed_bum_aurora" src="https://github.com/user-attachments/assets/0e993f4d-dd18-437e-86fc-57debb97f91a" />
      </td>
    </tr>
  </tbody>
</table>

TL;DR: 0.3.0 bad, 0.3.1 better

## [0.3.0] - 2026-08-04 [YANKED]

> [!WARNING]
> This version leaks memory for every rendered frames.


### Added

- Maniac now set the terminal title to the current shader name
- The shader will pause when the window is not focused, and resume when it is focused again
- A `--shut-up` flag to disable default unfocused screensaver message

### Changed

- Properly centered the header title
- Fixed the footer render to be more consistent with the header and ellipsis

## [0.2.0] - 2026-08-02

### Added

- Added more shaders
- Improve the footer render
- Fixed workflow release (which stopped 0.1.0) from being released

### Fixed

- Fixed header flickering issue on ghostty, when the mode is set to headless

## [0.1.0] - (Unreleased)

- Initial release of the project.
