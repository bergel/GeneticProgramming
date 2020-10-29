# GeneticProgramming

[![Build Status](https://travis-ci.com/bergel/GeneticProgramming.svg?branch=grammar)](https://travis-ci.com/bergel/GeneticProgramming)

## How to load



```Smalltalk
[Metacello new
    baseline: 'Roassal3';
    repository: 'github://ObjectProfile/Roassal3';
    load: 'Full' ] on: MCMergeOrLoadWarning do: [:warning | warning load ]

Metacello new
 baseline:'GeneticProgramming';
repository: 'github://bergel/GeneticProgramming:grammar/src';
 load.
```

## Example 

Consider the following simple grammar:
```
E -> Number
E -> E + E
```

It can be implemented using:

```Smalltalk
grammar := GPContextFreeGrammar new.
grammar addRule: #E withSequence: #( #E #AddOp #E ).
grammar addRule: #E withSequence: #( #Number ).
grammar addMessageRule: #AddOp withValues: #( #+ ).
grammar addLeafRule: #Number withValues: (-30 to: 30).
```

An AST can be generated using:
```Smalltalk
grammar expandFrom: #E
```

## Adding a configuration

```Smalltalk
config := GPASTConfiguration new.
config depth: 3.
ast := grammar expandFrom: #E given: config.
```

In that case, the depth of the tree will be maximum 3.
