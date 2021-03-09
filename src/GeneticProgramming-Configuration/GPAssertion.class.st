Class {
	#name : #GPAssertion,
	#superclass : #Object,
	#instVars : [
		'individuals',
		'dictDepth',
		'options',
		'configuration',
		'metrics',
		'contexts'
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
GPAssertion >> calculateCallsMetric: tSelector [
	| t originalMethod aBehavior |
	self assert: configuration testClass notNil.
	self assert: configuration targetClass notNil.
	aBehavior := configuration targetClass instanceSide.
	originalMethod := aBehavior compiledMethodAt: tSelector.
	[ self injectInto: tSelector given: originalMethod ] on: Error do: [ 
		self uninstallOf: originalMethod.
	].
	t := configuration testClass buildSuite run.
	metrics at: 'numCalls'
		ifAbsentPut: [ Dictionary new ].
	(metrics at: 'numCalls') at: tSelector put: (GPCounter instance occurrencesOf: tSelector).
	self uninstallOf: originalMethod.
	"val := contexts 
		ifEmpty: [ OrderedCollection new add: (self countErrors: tSelector given: tC new); yourself ] 
		ifNotEmpty: [ contexts collect: [ :ctx | self countErrors: tSelector given: ctx ] ]."
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateErrorMetric: tSelector [
	| tC val |
	self assert: configuration targetClass notNil.
	tC := configuration targetClass.
	val := contexts 
		ifEmpty: [ OrderedCollection new add: (self countErrors: tSelector given: tC new); yourself ] 
		ifNotEmpty: [ contexts collect: [ :ctx | self countErrors: tSelector given: ctx ] ].
	metrics at: 'numErrors'
		ifAbsentPut: [ Dictionary new ].
	(metrics at: 'numErrors') at: tSelector put: val min
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateMetrics: tSelector [
	self calculateErrorMetric: tSelector.
	self calculateCallsMetric: tSelector 
]

{ #category : #'as yet unclassified' }
GPAssertion >> countErrors: targetSelector given: object [
	| rm |
	rm := GPRandom instance.
	^ (1 to: 30) inject: 0 into: [ :sum :num | | args |
		args := (1 to: targetSelector numArgs) collect: [ :a | 
		        rm randomlySelect: self options ].
		sum + ([ object perform: targetSelector withArguments: args.
			0 ]
			on: Error
			do: [ :ex | 1 ])
	]
]

{ #category : #accessing }
GPAssertion >> filename [
	^ (configuration targetClass name, '.csv') asFileReference 
]

{ #category : #'as yet unclassified' }
GPAssertion >> for: symbol putDepth: number [
	self assert: number isNumber.
	self assert: number > 0.
	dictDepth at: symbol put: number
]

{ #category : #'as yet unclassified' }
GPAssertion >> getBestIndividualGiven: aSelector [
	| engine |
	engine := GPEngine new.
	configuration 
		targetSelector: aSelector;
		options: self options.
	dictDepth at: aSelector ifPresent: [ :n | configuration depth: n ].
	engine configuration: configuration.
	engine execute.
	^ engine "pickBestIndividual "
]

{ #category : #'as yet unclassified' }
GPAssertion >> getBestIndividualGiven: aSelector given: index [
	| engine |
	engine := GPEngine new.
	configuration 
		targetSelector: aSelector;
		options: self options;
		index: index.
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
	options := OrderedCollection new.
	metrics := Dictionary new.
	contexts := OrderedCollection new
]

{ #category : #'as yet unclassified' }
GPAssertion >> injectInto: tSelector given: originalMethod [
	| rbMethodNode |
	rbMethodNode := RBParser
		parseMethod: originalMethod sourceCode.
	rbMethodNode body addNodeFirst: (RBParser parseExpression: 'GPCounter addOccurrence: ''', tSelector, '''').
	configuration targetClass compile: rbMethodNode printString notifying: nil.
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
	self assert: configuration targetSelectors notEmpty.
	GPCounter reset.
	individuals := Dictionary 
		newFromAssociations: (configuration targetSelectors 
			collect: [ :tSelector |
				self calculateMetrics: tSelector.
				tSelector -> (self getBestIndividualGiven: tSelector)
				"tSelector -> ((1 to: tSelector numArgs) collect: [:n | 
					 (self getBestIndividualGiven: tSelector given: n) ])"])
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

{ #category : #'as yet unclassified' }
GPAssertion >> uninstallOf: originalMethod [
	self assert: configuration targetClass notNil.
	configuration targetClass methodDict at: originalMethod selector put: originalMethod 
]

{ #category : #writing }
GPAssertion >> writeOnCsv [
	| data  |
	self assert: individuals notEmpty.
	self assert: metrics notEmpty.
	data := (configuration targetSelectors collect: [ :s | | best |
		best := (individuals at: s) pickBestIndividual.
		OrderedCollection new 
			add: configuration targetClass;
			add: s;
			add: ((metrics at: 'numErrors') at: s);
			add: ((metrics at: 'numCalls') at: s);
			add: best print;
			add: best fitness;
			yourself	]).
	self filename writeStreamDo: [ :stream |
		(NeoCSVWriter on: stream)
			nextPut: #(Class Method Errors Calls Result Fitness);
			nextPutAll: data;
			flush
	]
]
