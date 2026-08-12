#!/usr/bin/env bash
# $1: path to the old config
# $2: path to the new config
# For every key in either config, sorted by key ascending: print
# "- KEY=old_value" then "+ KEY=new_value" if changed, "- KEY=old_value"
# if only in the old config, "+ KEY=new_value" if only in the new
# config. Print nothing for keys unchanged between the two configs.
