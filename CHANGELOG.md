# Changelog

## v0.2.0 (2025-07-16)

The library is now fully refactored with a clear structure and consistent naming. The sound naming issue in v0.1.0 has been fixed.

### Features

- Add `sin/0`, `saw/0`, and `pulse/0` oscillator functions replacing `osc/1`
- Add `pan/1` with `pos/2` and `level/2` for stereo panning control

### Enhancements

- Refactor `Supex` for consistent syntax, naming, and improved internal structure
- Improve documentation for all public functions

### Deprecations

- Deprecate `osc/0` and `osc/1` in favor of specific oscillator functions (`sin/0`, `saw/0`, `pulse/0`)

### Bug Fixes

- Fix naming handling in `play/2` for multi-character names
- Correct typespecs for oscillator modifier functions

### Breaking Changes

- Remove `Synth` (`Supex.synth/0`) and `Example` modules

### Documentation

- Update examples and README for clarity and accuracy

## v0.1.1 (2025-07-10)

### Enhancements

- Refactored `lfo/1` in `Spex` and `Ugen` modules.

### Bug Fixes

- Corrected typespecs in `Spex` and `Ugen` modules.
