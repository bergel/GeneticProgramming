Class {
	#name : #GPRuleOptionTest,
	#superclass : #TestCase,
	#instVars : [
		'ruleOption'
	],
	#category : #'GeneticProgramming-Tests'
}

{ #category : #running }
GPRuleOptionTest >> setUp [
	ruleOption := GPRuleOption new
]

{ #category : #tests }
GPRuleOptionTest >> testAddNodeWithOptions [
	| res |
	ruleOption ruleName: #E;
		addNode: (GPNode new id: #E; type: RBLiteralNode) withValueOptions: (1 to: 5);
		addNode: (GPNode new id: #E; type: RBVariableNode) withValueOptions: #(#name #size #shape).
	self assert: ruleOption nodes size equals: 2.
	res := ruleOption getNodeWithOptionsAt: 1.
	self assert: res key class equals: GPNode.
	self assert: res key type equals: RBLiteralNode.
	self assertCollection: res value hasSameElements: #(1 2 3 4 5).
	res := ruleOption getNodeWithOptionsAt: 2.
	self assert: res key class equals: GPNode.
	self assert: res key type equals: RBVariableNode.
	self assertCollection: res value hasSameElements: #(#name #size #shape).
]

{ #category : #tests }
GPRuleOptionTest >> testAllOptions [
	| options |
	ruleOption ruleName: #E;
		addNode: (GPNode new id: #E; type: RBMessageNode; children: #(#E #Add #T) asOrderedCollection);
		addNodeOption: #T;
		addNodeOption: #F;
		addNode: (GPNode new id: #E; type: RBAssignmentNode; children: #(#Var #F) asOrderedCollection).
	options := ruleOption allOptions.
	self assert: options size equals: 4.
	self assertCollection: (options collect: #key) hasSameElements: #('node' 'nodeOption' 'nodeOption' 'node').
	options := options collect: #value.
	self assert: options first key class equals: GPNode.
	self assert: options first key type equals: RBMessageNode.
	self assert: options second equals: #T.
	self assert: options third equals: #F.
	self assert: options fourth key class equals: GPNode.
	self assert: options fourth key type equals: RBAssignmentNode.
]

{ #category : #tests }
GPRuleOptionTest >> testGetNodeAt [
	ruleOption 
		ruleName: #E;
		addNode: (GPNode new id: #E; type: RBLiteralNode; printBlock: [:n :ctx | n nodeValue asString ]);
		addNode: (GPNode new id: #E; type: RBVariableNode).
	self assert: ruleOption ruleName equals: #E.
	self assert: (ruleOption getNodeAt: 1) class equals: (ruleOption getNodeAt: 2) class.
	self assert: (ruleOption getNodeAt: 1) type equals: RBLiteralNode.
	self assert: (ruleOption getNodeAt: 2) type equals: RBVariableNode.
	
		
]

{ #category : #tests }
GPRuleOptionTest >> testGetNodeOptionAt [
	ruleOption 
		ruleName: #E;
		addNodeOption: (1 to: 5) asArray;
		addNodeOption: #('name' 'size' 'shapes').
	self assertCollection: (ruleOption getNodeOptionAt: 1) equals: #(1 2 3 4 5).
	self assertCollection: (ruleOption getNodeOptionAt: 2) equals: #('name' 'size' 'shapes').
	
	
		
]

{ #category : #tests }
GPRuleOptionTest >> testGetValueOptionsAt [
	ruleOption 
		ruleName: #E;
		addNode: nil withValueOptions: (1 to: 5) asArray;
		addNode: nil withValueOptions: #('name' 'size' 'shapes').
	self assertCollection: (ruleOption getValueOptionsAt: 1) equals: #(1 2 3 4 5).
	self assertCollection: (ruleOption getValueOptionsAt: 2) equals: #('name' 'size' 'shapes').
	
	
		
]
