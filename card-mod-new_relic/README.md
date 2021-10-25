<!--
# @title README - mod: new relic
-->

# NewRelic mod (experimental)

NewRelic is a sophisticated web-based performance tracking tool.

This mod supports integration with NewRelic by adding tracers for important
methods like `Card#fetch`, `Format#final_render`, `Card::Query.new`, 
`Voo.process`, and for action events.

There are also _many_ other tracers not activated but that can easily be
copied from the source code here and reused in a local mod.

To attach this mod to your NewRelic account, add a `newrelic.yml` file in the
deck's `config` directory. 

For full documentation of agent configuration options, please refer to
https://docs.newrelic.com/docs/agents/ruby-agent/installation-configuration/ruby-agent-configuration
