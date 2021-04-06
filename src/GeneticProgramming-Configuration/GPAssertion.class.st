Class {
	#name : #GPAssertion,
	#superclass : #Object,
	#instVars : [
		'individuals',
		'dictDepth',
		'options',
		'configuration',
		'metrics',
		'contexts',
		'packageRegexs',
		'optionsDict',
		'directoryName',
		'results',
		'nameFileResult'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPAssertion >> addAutomaticallyOptions [
	self addOptionClasses: (Array with: configuration targetClass name).
	self addOptionSelectors: (self collectTestingSelectors: (Array with: configuration targetClass)).
]

{ #category : #adding }
GPAssertion >> addDataOfNameSelectors: dictionary given: node [
	| selectorNodes dict |
	selectorNodes := node withAllChildren select: [ :ch | 
				ch class = GPSelectorNode and: [ ch id ~= #Assert ] ].
	dict := selectorNodes groupedBy: #id.
	dict associationsDo: [ :assoc | | val |
		val := dictionary at: assoc key ifAbsent: [ 0 ].
		dictionary at: assoc key	put: val + assoc value size
	].
	dict at: #Satisfy ifPresent: [ :val | | messageVal |
		messageVal := dictionary at: #Message ifAbsent: [ 0 ].
		dictionary at: #Message put: messageVal - val	size
	]
]

{ #category : #adding }
GPAssertion >> addOptionArgs: collection [
	configuration addOptionArgs: collection
]

{ #category : #adding }
GPAssertion >> addOptionClasses: classNames [
	"configuration addOptionClasses: classNames."
	self assert: classNames isCollection.
	classNames ifNotEmpty: [ 
		optionsDict at: #class put: classNames
	]
]

{ #category : #adding }
GPAssertion >> addOptionSelectors: selectors [
	"configuration addOptionSelectors: selectors."
	self assert: selectors isCollection.
	selectors ifNotEmpty: [ 
		optionsDict at: #selector put: selectors
	]
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
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateErrorMetric: tSelector given: protocol [
	| tC val res |
	self assert: configuration targetClass notNil.
	tC := configuration targetClass.
	val := contexts 
		ifEmpty: [ res := [ self countErrors: tSelector given: protocol and: tC new ] on: Error do: [ Array with: 0 with: self options ].
			configuration options: res second.
			OrderedCollection new add: res first; yourself ] 
		ifNotEmpty: [ contexts collect: [ :ctx | 
				res := self countErrors: tSelector given: protocol and: ctx.
				configuration options: res second.
				res first ] ].
	metrics at: 'numErrors'
		ifAbsentPut: [ Dictionary new ].
	(metrics at: 'numErrors') at: tSelector put: val min
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateMetrics: tSelector given: protocol [
	self calculateErrorMetric: tSelector given: protocol.
	self calculateCallsMetric: tSelector 
]

{ #category : #'as yet unclassified' }
GPAssertion >> collectTestingSelectors: classes [
	^ (classes flatCollect: [ :cls | 
		(cls methodsInProtocol: #testing) collect: #selector ])
	select: [ :s | s numArgs == 0 ]
]

{ #category : #accessing }
GPAssertion >> contexts: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	contexts := collection.
	configuration contexts: collection 
]

{ #category : #'as yet unclassified' }
GPAssertion >> countErrors: targetSelector given: protocol and: object [
	| rm opts newOpts res i size |
	opts := self options.
	size := opts size.
	newOpts := OrderedCollection new.
	rm := GPRandom instance.
	res := i := 0.
	[ i < 10 and: [ res < 30 ] ] whileTrue: [ 
		i := i + 1.
		res := (1 to: 30) inject: 0 into: [ :sum :num | | args |
			args := (1 to: targetSelector numArgs) collect: [ :a | 
		        rm randomlySelect: opts ].
			sum + ([ object perform: targetSelector withArguments: args.
				protocol = #accesing ifTrue: [ newOpts addAll: args ].
				0 ]
			on: Exception
			do: [ :ex | newOpts addAll: args.
				1 ]) ].
		opts := newOpts ].
	^ Array with: res with: opts
]

{ #category : #accessing }
GPAssertion >> directoryName: string [
	self assert: (string isString and: [ string notEmpty ]).
	directoryName := string
]

{ #category : #accessing }
GPAssertion >> filename [
	(directoryName notNil and: [directoryName notEmpty ])
		ifTrue: [ | directory ref |
			directory := FileSystem disk workingDirectory.
			ref := directory / directoryName.
			ref ensureCreateDirectory
		].
	^ ((directoryName ifNil: [ '' ] ifNotNil: [ directoryName ifEmpty: [ directoryName ] ifNotEmpty: [ directoryName, '/' ] ]) , 
		configuration targetClass name, '.csv') asFileReference 
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
	contexts := OrderedCollection new.
	packageRegexs := OrderedCollection new.
	optionsDict := Dictionary new.
	directoryName := ''.
	results := OrderedCollection new.
	nameFileResult := 'result'
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
GPAssertion >> nameResultFile [ 
	^ (nameFileResult, '.csv') asFileReference 
]

{ #category : #'as yet unclassified' }
GPAssertion >> nameResultFile: string [
	self assert: (string isString and: [ string notEmpty ]).
	nameFileResult := string
]

{ #category : #accessing }
GPAssertion >> options [
	options ifEmpty: [ 
		options := OrderedCollection new 
			add: nil;
			add: Color blue;
			add: #();
			add: '';
			add: 'hello';
			add: Dictionary new;
			add: (-1000 to: 1000) asArray;
			add: 0;
			add: -1;
			add: 1;
			add: OrderedCollection new;
			add: -1.0;
			add: 1.0;
			add: #r;
			add: $5;
			add: true;
			add: false;
			add: Object new;
			add: ((1 to: 1000) collect: [:n | 
				GPRandom instance randomlySelect: String loremIpsum substrings
				]);
			yourself ].
	^ options
	 
]

{ #category : #accessing }
GPAssertion >> options: collection [
	self assert: collection isCollection.
	options := collection.
	configuration options: collection  
	 
]

{ #category : #running }
GPAssertion >> run [
	| dict |
	self assert: configuration targetClass notNil.
	configuration 
		addOptionClasses: (optionsDict at: #class ifAbsent: [#()]);
		addOptionSelectors: (optionsDict at: #selector ifAbsent: [#()])";
		depth: 3".
	configuration targetSelectors ifEmpty: [ 
		individuals := Dictionary new.
		^ self ].
	GPCounter reset.
	dict := (configuration targetClass methods collect: [ :cMethod |
		cMethod selector -> cMethod protocol	
	]) asDictionary.
	individuals := Dictionary 
		newFromAssociations: (configuration targetSelectors 
			select: [ :tSelector |
				self calculateMetrics: tSelector given: (dict at: tSelector ifAbsent: [ nil ]).
				((metrics at: 'numCalls') at: tSelector ifAbsent: [ 0 ]) > 0 ]
			thenCollect: [:tSelector |
				tSelector -> (self getBestIndividualGiven: tSelector) ]).
	self summaryOfEvolutionData
]

{ #category : #running }
GPAssertion >> runAllClasses [

	| selectedClasses packageClasses |
	self assert: packageRegexs notEmpty.
	packageClasses := packageRegexs flatCollect: [ :regex | 
		self selectPackageClasses: regex	
	].
	selectedClasses := self selectCandidateClasses: packageClasses.
	"selectedClasses := packageRegexs flatCollect: [ :regex | 
		           self selectCandidateClasses: regex ]."
	selectedClasses do: [ :cl | 
		configuration := GPAssertConfiguration new.
		self targetClass: cl.
		self testClass: (self class environment at: cl name , 'Test').
		self options: self options.
		self addOptionClasses: (packageClasses collect: #name).
		self addOptionSelectors: (self collectTestingSelectors: packageClasses).
		(optionsDict at: #class ifAbsent: [ #() ]) ifNotEmpty: [ self addOptionClasses: (optionsDict at: #class)].
		(optionsDict at: #selector ifAbsent: [ #() ] ) ifNotEmpty: [ self addOptionSelectors: (optionsDict at: #selector) ].
		self run.
		individuals ifNotEmpty: [ self writeOnCsv ] ]
]

{ #category : #running }
GPAssertion >> runAllClasses: collection [

	| selectedClasses packageClasses |
	self assert: packageRegexs notEmpty.
	packageClasses := packageRegexs flatCollect: [ :regex | 
		self selectPackageClasses: regex	
	].
	selectedClasses := (self selectCandidateClasses: packageClasses) reject: [:cls |
		collection includes: cls	
	].
	"selectedClasses := packageRegexs flatCollect: [ :regex | 
		           self selectCandidateClasses: regex ]."
	selectedClasses do: [ :cl | 
		configuration := GPAssertConfiguration new.
		self targetClass: cl.
		self testClass: (self class environment at: cl name , 'Test').
		self options: self options.
		self addOptionClasses: (packageClasses collect: #name).
		self addOptionSelectors: (self collectTestingSelectors: packageClasses).
		(optionsDict at: #class ifAbsent: [ #() ]) ifNotEmpty: [ self addOptionClasses: (optionsDict at: #class)].
		(optionsDict at: #selector ifAbsent: [ #() ] ) ifNotEmpty: [ self addOptionSelectors: (optionsDict at: #selector) ].
		self run.
		individuals ifNotEmpty: [ self writeOnCsv ] ]
]

{ #category : #running }
GPAssertion >> runAllClassesExcept: collection [

	self runAllClasses: collection
]

{ #category : #'as yet unclassified' }
GPAssertion >> selectCandidateClasses: classes [
	| names |
	"packages := RPackageOrganizer default packages select: [:p | regex match: p name asString ].
	classes := packages 
					inject: #() 
					into: [:sum :el | sum, (el classes reject: #isTrait) asOrderedCollection ]."
	names := classes collect: #name thenSelect: [:n | n endsWith: 'Test'].
	^ (classes reject: [ :c | c name endsWith: 'Test' ]) 
		select: [ :c | names includes: c name, 'Test' ].
						
]

{ #category : #'as yet unclassified' }
GPAssertion >> selectPackageClasses: regex [
	| packages |
	packages := RPackageOrganizer default packages select: [:p | regex match: p name asString ].
	^ packages 
			inject: #() 
			into: [:sum :el | sum, (el classes reject: #isTrait) asOrderedCollection ].
]

{ #category : #'as yet unclassified' }
GPAssertion >> summaryOfEvolutionData [
	| col nCalledMets nSuccMets nEvolMets nSuccEvolMets dictMessages |
	col := OrderedCollection new
		add: configuration targetClass name;
		add: configuration targetSelectors size;
		yourself.
	dictMessages := Dictionary new.
	nCalledMets := nSuccMets := nEvolMets := nSuccEvolMets := 0.
	individuals associationsDo: [ :assoc | 
		((metrics at: 'numCalls') at: assoc key) > 0 ifTrue: [ | bestFitness bestIndiv |
			nCalledMets := nCalledMets + 1.
			(assoc value population isEmpty or: [ assoc value population allSatisfy: #isNil ])
				ifFalse: [ 
					bestFitness := assoc value logs first bestFitnessValue.
					bestIndiv := assoc value pickBestIndividual. 
					bestIndiv fitness == 0 ifTrue: [ nSuccMets := nSuccMets + 1 ].
					bestFitness > bestIndiv fitness ifTrue: [ 
						nEvolMets := nEvolMets + 1.
						bestIndiv fitness == 0 ifTrue: [ nSuccEvolMets := nSuccEvolMets + 1 ] ].
					self addDataOfNameSelectors: dictMessages given: bestIndiv ]
		]
	].
	col 
		add: nCalledMets;
		add: nSuccMets; 
		add: nCalledMets - nSuccMets; 
		add: nEvolMets; 
		add: nSuccEvolMets;
		add: (dictMessages at: #Message ifAbsent: [ 0 ]);
		add: (dictMessages at: #Message1 ifAbsent: [ 0 ]);
		add: (dictMessages at: #Satisfy ifAbsent: [ 0 ]);
		add: (dictMessages at: #Comparison ifAbsent: [ 0 ]);
		add: (dictMessages at: #And ifAbsent: [ 0 ]).
	results add: col
]

{ #category : #accessing }
GPAssertion >> targetClass: aClass [
	self assert: aClass notNil.
	configuration targetClass: aClass 
]

{ #category : #'as yet unclassified' }
GPAssertion >> targetPackageRegexs: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	packageRegexs := collection
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
	data := (configuration targetSelectors collect: [ :s | | best e |
		e := individuals at: s ifAbsent: [ nil ].
		[ best := e pickBestIndividual.
		OrderedCollection new 
			add: configuration targetClass;
			add: s;
			add: ((metrics at: 'numErrors') at: s);
			add: ((metrics at: 'numCalls') at: s);
			add: best print;
			add: e logs first bestFitnessValue;
			add: best fitness;
			yourself ] on: Error do: [ :err | nil ]] thenSelect: [:d | d notNil ]).
	
	data ifNotEmpty: [ 
		self filename writeStreamDo: [ :stream |
			(NeoCSVWriter on: stream)
				nextPut: #(Class Method Errors Calls Result FstFitness LstFitness);
				nextPutAll: data;
				flush ] 
	]
]

{ #category : #writing }
GPAssertion >> writeResults [
	results ifNotEmpty: [ 
		self nameResultFile writeStreamDo: [ :stream |
			(NeoCSVWriter on: stream)
				nextPut: #(Class Methods CalledMethods MethodsWithFitnessZero MethodsWithFitnessGreaterThanZero MethodsWithEvolution MethodsWithSuccessEvolution Message Message1 Satisfy Comparison And);
				nextPutAll: results;
				flush ] 
	]
]
