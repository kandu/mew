# mew — Modal Editing Witch

[![Build Status](https://travis-ci.org/kandu/mew.svg?branch=master)](https://travis-ci.org/kandu/mew)

This is the core module of mew, a general modal editing engine generator.

## Usage

You can provide your `Key`, `Mode`, `Concurrent` modules to define the real world environment to get the core component of a modal editing engine.

The core compoment support recursive key mapping ossociated with user provided modes. 

After the core component is generated, you may extend it with a translater to interpret user key sequence, so you'll get a complete modal editing engine.
