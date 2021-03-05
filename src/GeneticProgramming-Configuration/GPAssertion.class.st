Class {
	#name : #GPAssertion,
	#superclass : #Object,
	#instVars : [
		'individuals',
		'dictDepth',
		'options',
		'configuration'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPAssertion >> addOptionArgs: collection [
	configuration addOptionArgs: collection
]

{ #category : #adding }
GPAssertion >> addOptionClasses: classNames [
	configuration addOptionClasses: classNames
]

{ #category : #adding }
GPAssertion >> addOptionSelectors: selectors [
	configuration addOptionSelectors: selectors
]

{ #category : #adding }
GPAssertion >> addRule: symbol withValues: collection [
	configuration addRule: symbol withValues: collection
]

{ #category : #adding }
GPAssertion >> addVariableRule: symbol withValues: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	configuration addVariableRule: symbol withValues: collection
]

{ #category : #'as yet unclassified' }
GPAssertion >> for: symbol putDepth: number [
	self assert: number isNumber.
	self assert: number > 0.
	dictDepth at: symbol put: number
]

{ #category : #'as yet unclassified' }
GPAssertion >> getBestIndividualGiven: aSelector given: index [
	| engine |
	engine := GPEngine new.
	configuration 
		targetSelector: aSelector;
		options: self options;
		index: index.
	"configuration := GPAssertConfiguration new
		targetClass: targetClass;
		testClass: testClass;
		targetSelectors: targetSelectors;
		targetSelector: aSelector;
		options: self options."
	dictDepth at: aSelector ifPresent: [ :n | configuration depth: n ].
	engine configuration: configuration.
	engine execute.
	^ engine "pickBestIndividual "
]

{ #category : #accessing }
GPAssertion >> individuals [
	^ individuals
]

{ #category : #initialization }
GPAssertion >> initialize [
	dictDepth := Dictionary new.
	configuration := GPAssertConfiguration new.
	options := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GPAssertion >> options [
	options ifEmpty: [ 
		options := OrderedCollection new
			add:  nil;
			add: 42;
			add: 'hello';
			add: 0;
			add: 1.2;
			add: #();
			add: -4;
			add: '';
			yourself ].
	^ options
	 
]

{ #category : #'as yet unclassified' }
GPAssertion >> options: collection [
	self assert: collection isCollection.
	options := collection
	 
]

{ #category : #running }
GPAssertion >> run [
	self assert: configuration targetClass notNil.
	individuals := Dictionary 
		newFromAssociations: (configuration targetSelectors 
			collect: [ :tSelector | 
				tSelector -> ((1 to: tSelector numArgs) collect: [:n | 
					 (self getBestIndividualGiven: tSelector given: n) ])])
]

{ #category : #accessing }
GPAssertion >> targetClass: aClass [
	self assert: aClass notNil.
	configuration targetClass: aClass 
]

{ #category : #accessing }
GPAssertion >> targetSelectors: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	configuration targetSelectors: collection 
	
]

{ #category : #accessing }
GPAssertion >> testClass: aClass [
	self assert: aClass notNil.
	configuration testClass: aClass 
]
