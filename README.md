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
grammar addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #E ).
grammar addRule: #E redirectingTo: #Number.
grammar addMessageRule: #AddOp withValues: #( #+ ).
grammar addLeafRule: #Number ofClass: RBLiteralNode withValues: (-30 to: 30).
```

A meta-tree can be generated using:
```Smalltalk
tree := grammar expandFrom: #E.
```

An ast (therefore directly evaluable) can be generated using:
```Smalltalk
ast := grammar generateASTFrom: tree.
```

## Adding a configuration

```Smalltalk
config := GPASTConfiguration new.
config depth: 3.
ast := grammar expandFrom: #E given: config.
```

In that case, the depth of the tree will be maximum 3.

## ETF Example

Here another example:
```Smalltalk
GPRandom instance seed: 10.

grammar := GPContextFreeGrammar new.
grammar 
         addRule: #E ofClass: RBMessageNode withSequence: #( #E #AddOp #T );
	 addMessageRule: #AddOp withValues: #( #+ );
         addRule: #E redirectingTo: #T;

	 addRule: #T ofClass: RBMessageNode  withSequence: #( #T #MultOp #F );
	 addMessageRule: #MultOp withValues: #( #* );
	 addRule: #T redirectingTo: #F;

	 addLeafRule: #F ofClass: RBLiteralNode withValues: ((1 to: 10)).

result := OrderedCollection new.
1000 timesRepeat: [
	tree := grammar expandFrom: #E.
	ast := grammar generateASTFrom: tree.
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

grammar addMessageRule: #AddOp withValues: #( #+ ).
grammar addLeafRule: #Number ofClass: RBLiteralNode withValues: (-30 to: 30).
grammar addLeafRule: #Variable ofClass: RBVariableNode withValues: #('x').

config := GPASTConfiguration new.
config addOptionWeights: #( 100 10 10 ) forRule: #E.

tree := grammar expandFrom: #E given: config.
ast := grammar generateASTFrom: tree.
```

## Setting a seed for the random number generation

Simply perform:

```Smalltalk
GPRandom instance seed: 10.
```

## Simple shortcut

The following two lines are equivalent:

```Smalltalk
grammar addRule: #E ofClass: RBMessageNode withSequence: #( #foo #bar ).
grammar addMessageRule: #E withValues: #( #foo #bar ).
```

Both `#foo` and `#bar` are selector used in message.
