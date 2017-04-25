# 547-project

## Build & development

Run `npm install` and `bower install` to install dependencies

Run `grunt` to build for production and `grunt serve` to run dev server.

## File structure

- All coffeescript files location in `app/scripts/`
  - Charts & all D3 functionality implemented in `app/scripts/directives/`
  - Control flow in `app/scripts/controllers/`
  - Data and util helpers in `app/scripts/services/`
- View templates in `app/views/`
- CSS in `app/styles/`
- Synthetic data generated from `data/sampler.py`