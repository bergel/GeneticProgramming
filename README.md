# GeneticProgramming

[![Build Status](https://travis-ci.com/bergel/GeneticProgramming.svg?branch=grammar)](https://travis-ci.com/bergel/GeneticProgramming)

## How to load


```Smalltalk
Metacello new
 baseline:'GeneticProgramming';
repository: 'github://bergel/GeneticProgramming:grammar/src';
 load.
 ```

To install the version with visualization type:

```Smalltalk
[Metacello new
    baseline: 'Roassal3';
    repository: 'github://ObjectProfile/Roassal3';
    load: 'Full' ] on: MCMergeOrLoadWarning do: [:warning | warning load ]

Metacello new
 baseline:'GeneticProgramming';
repository: 'github://bergel/GeneticProgramming:grammar/src';
load: #('All').
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
grammar addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #E ).
grammar addRule: #E redirectingTo: #Number.
grammar addSelectorRule: #AddOp withValues: #( #+ ).
grammar addLeafRule: #Number ofClass: RBLiteralNode withValues: (-30 to: 30).
```

A meta-tree can be generated using:
```Smalltalk
tree := grammar expandTree: #E.
```

An ast (therefore directly evaluable) can be generated using:
```Smalltalk
ast := tree ast.
```

## Adding a configuration

```Smalltalk
config := GPASTConfiguration new.
config depth: 3.
ast := grammar expandTree: #E given: config.
```

In that case, the depth of the tree will be maximum 3.

## ETF Example

Here another example:
```Smalltalk
GPRandom instance seed: 10.

grammar := GPContextFreeGrammar new.
grammar 
         addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
	 addSelectorRule: #AddOp withValues: #( #+ );
         addRule: #E redirectingTo: #T;
	 addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 addSelectorRule: #MultOp withValues: #( #* );
	 addRule: #T redirectingTo: #F;
	 addLeafRule: #F ofClass: RBLiteralNode withValues: ((1 to: 10)).

result := OrderedCollection new.
1000 timesRepeat: [
	tree := grammar expandTree: #E.
	ast := tree ast.
	result add: ast formattedCode
].
result
```

## Specifying priorities

```Smalltalk
grammar := GPContextFreeGrammar new.
grammar addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #E ).
grammar addRule: #E redirectingTo: #Number.
grammar addRule: #E redirectingTo: #Variable.
grammar addSelectorRule: #AddOp withValues: #( #+ ).
grammar addLeafRule: #Number ofClass: RBLiteralNode withValues: (-30 to: 30).
grammar addLeafRule: #Variable ofClass: RBVariableNode withValues: #('x').
config := GPASTConfiguration new.
config addOptionWeights: #( 100 10 10 ) forRule: #E.

tree := grammar expandTree: #E given: config.
ast := tree ast.
```

## Setting a seed for the random number generation

Simply perform:

```Smalltalk
GPRandom instance seed: 10.
```
