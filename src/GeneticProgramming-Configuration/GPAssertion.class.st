Class {
	#name : #GPAssertion,
	#superclass : #Object,
	#instVars : [
		'individuals',
		'options',
		'metrics',
		'contextBlocks',
		'packageRegexs',
		'optionsDict',
		'directoryName',
		'results',
		'nameResultFile',
		'exportVisualization',
		'targetClass',
		'testClass',
		'targetSelectors'
	],
	#category : #'GeneticProgramming-Configuration-GPAssert'
}

{ #category : #adding }
GPAssertion >> addAutomaticallyOptions [
	self addOptionClasses: (Array with: "configuration" targetClass name).
	self addOptionSelectors: (self collectTestingSelectors: (Array with: "configuration" targetClass)).
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
	"configuration addOptionArgs: collection"
]

{ #category : #adding }
GPAssertion >> addOptionClasses: classNames [
	self assert: classNames isCollection.
	classNames ifNotEmpty: [ 
		optionsDict at: #class put: classNames
	]
]

{ #category : #adding }
GPAssertion >> addOptionSelectors: selectors [
	self assert: selectors isCollection.
	selectors ifNotEmpty: [ 
		optionsDict at: #selector put: selectors
	]
]

{ #category : #adding }
GPAssertion >> addRule: symbol withValues: collection [
	"configuration addRule: symbol withValues: collection"
]

{ #category : #adding }
GPAssertion >> addVariableRule: symbol withValues: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	"configuration addVariableRule: symbol withValues: collection"
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateCallsMetric: tSelector [
	| t originalMethod aBehavior |
	self assert: testClass isClass.
	self assert: targetClass isClass.
	aBehavior := targetClass instanceSide.
	originalMethod := aBehavior compiledMethodAt: tSelector.
	[ self injectInto: tSelector given: originalMethod ] on: Exception do: [ 
		self uninstallOf: originalMethod.
	].
	t := testClass buildSuite run.
	metrics at: 'numCalls'
		ifAbsentPut: [ Dictionary new ].
	(metrics at: 'numCalls') at: tSelector put: (GPCounter instance occurrencesOf: tSelector).
	self uninstallOf: originalMethod.
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateErrorMetric: tSelector given: protocol and: configuration [
	|  val res |
	self assert: targetClass isClass.
	val := contextBlocks
		ifEmpty: [ res := [ self countErrors: tSelector given: protocol and: [targetClass new] ] on: Exception do: [ Array with: 0 with: self options ].
			configuration options: res second.
			OrderedCollection new add: res first; yourself ] 
		ifNotEmpty: [ contextBlocks collect: [ :block | 
				res := self countErrors: tSelector given: protocol and: block.
				configuration options: res second.
				res first ] ].
	metrics at: 'numErrors'
		ifAbsentPut: [ Dictionary new ].
	(metrics at: 'numErrors') at: tSelector put: val min
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateMetrics: tSelector given: protocol and: configuration [
	self calculateErrorMetric: tSelector given: protocol and: configuration.
	self calculateCallsMetric: tSelector 
]

{ #category : #'as yet unclassified' }
GPAssertion >> calculateNumberOfFailures [ 
	| t |
	self assert: testClass isClass.
	t := testClass buildSuite run.
	^ t errorCount + t failureCount 
]

{ #category : #'as yet unclassified' }
GPAssertion >> collectTestingSelectors: classes [
	^ (classes flatCollect: [ :cls | 
		(cls methodsInProtocol: #testing) collect: #selector ])
	select: [ :s | s numArgs == 0 ]
]

{ #category : #accessing }
GPAssertion >> contextBlocks: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	contextBlocks := collection
]

{ #category : #'as yet unclassified' }
GPAssertion >> countErrors: targetSelector given: protocol and: block [
	| rm opts newOpts res i size |
	opts := self options copy.
	size := opts size.
	newOpts := Set new.
	rm := GPRandom instance.
	res := i := 0.
	[ i < 10 and: [ res < 30 ] ] whileTrue: [ 
		i := i + 1.
		res := (1 to: 30) inject: 0 into: [ :sum :num | | args |
			args := (1 to: targetSelector numArgs) collect: [ :a | 
		        rm randomlySelect: opts ].
			sum + ([ block value perform: targetSelector withArguments: args.
				"if the method has accesing protocol, it means that args are not validated and just are assigned, that is the reason the values are added to the list"
				protocol = #accesing ifTrue: [ newOpts addAll: args ].
				0 ]
			on: Exception
			do: [ :ex | newOpts addAll: args.
				1 ]) ].
		opts := newOpts asOrderedCollection ].
	^ Array with: res with: opts
]

{ #category : #accessing }
GPAssertion >> directoryName: string [
	self assert: (string isString and: [ string notEmpty ]).
	directoryName := string
]

{ #category : #operations }
GPAssertion >> ensureDirectory [ 
	(directoryName notNil and: [directoryName notEmpty ])
		ifFalse: [ ^ self ]
		ifTrue: [ | directory ref |
			directory := FileSystem disk workingDirectory.
			ref := directory / directoryName.
			ref ensureCreateDirectory
		]
]

{ #category : #writing }
GPAssertion >> exportData: engine on: filename [
	| data metricNames generation |
	self assert: engine notNil.
	self assert: (filename isString and: [ filename notEmpty ]).
	metricNames := OrderedCollection new.
	generation := 0.
	data := (engine logs flatCollect: [ :log | | position |
		position := 1. 
		generation := generation + 1.
		log population collect: [ :ind | | col ableToAdd |
			ind generation: generation;
			position: position.
			col := OrderedCollection new 
				add: ind generation;
				add: ind position;
				add: ind fitness asNumber;
				yourself.
			ableToAdd := metricNames isEmpty.
			col addAll: (ind fitness objectives collect: [ :assoc | 
				ableToAdd ifTrue: [ metricNames add: assoc key ].
				assoc value ]).
			position := position + 1.
			col
		] ]).
	data ifNotEmpty: [ 
		filename asFileReference ensureDelete.
		filename asFileReference writeStreamDo: [ :stream |
			(NeoCSVWriter on: stream)
				nextPut: #(Generation Id Fitness), metricNames asArray;
				nextPutAll: data;
				flush ] 
	]
]

{ #category : #'as yet unclassified' }
GPAssertion >> exportEvolutionData [
	| dName |
	self ensureDirectory.
	dName := directoryName 
		ifNil: [ '' ] 
		ifNotNil: [ directoryName 
			ifEmpty: [ directoryName ] 
			ifNotEmpty: [ directoryName, '/' ] ].
	individuals valuesDo: [ :eng | | filename |
		filename := String streamContents: [ :stream | 
			stream
				nextPutAll: dName; 
				nextPutAll: targetClass name;
				nextPut: $_;
				nextPutAll: eng configuration targetSelector;
				nextPutAll: '_Data.csv' ].
		self exportData: eng on: filename
	]
]

{ #category : #accessing }
GPAssertion >> exportVisualization: boolean [
	self assert: (boolean or: [ boolean not ]).
	exportVisualization := boolean
]

{ #category : #accessing }
GPAssertion >> filename [
	self ensureDirectory.
	^ ((directoryName ifNil: [ '' ] ifNotNil: [ directoryName ifEmpty: [ directoryName ] ifNotEmpty: [ directoryName, '/' ] ]) , 
		targetClass name, '.csv') asFileReference 
]

{ #category : #'as yet unclassified' }
GPAssertion >> getBestIndividual: configuration [
	| engine |
	engine := GPEngine new.
	"dictDepth at: aSelector ifPresent: [ :n | configuration depth: n ]."
	engine configuration: configuration.
	engine execute.
	^ engine "pickBestIndividual "
]

{ #category : #'as yet unclassified' }
GPAssertion >> getBestIndividual: configuration given: index [
	| engine |
	engine := GPEngine new.
	configuration index: index.
	"dictDepth at: aSelector ifPresent: [ :n | configuration depth: n ]."
	engine configuration: configuration.
	engine execute.
	^ engine "pickBestIndividual "
]

{ #category : #'as yet unclassified' }
GPAssertion >> getSelectorCandidates [
	| numberOfFailures dict |
	numberOfFailures := self calculateNumberOfFailures.
	dict := (targetClass methods collect: [ :cMethod |
		cMethod selector -> cMethod protocol	
	]) asDictionary.
	^ targetSelectors collect: [ :tSelector | | configuration |
		configuration := GPAssertConfiguration new
			targetClass: targetClass;
			targetSelectors: targetSelectors;
			contextBlocks: contextBlocks;
			testClass: testClass;
			targetSelector: tSelector;
			numberOfFailures: numberOfFailures;
			addOptionClasses: (optionsDict at: #class ifAbsent: [#()]);
			addOptionSelectors: (optionsDict at: #selector ifAbsent: [#()]).
		self calculateMetrics: tSelector given: (dict at: tSelector ifAbsent: [ nil ]) and: configuration.
		tSelector -> configuration
		] thenSelect: [ :assoc | ((metrics at: 'numCalls') at: assoc key ifAbsent: [0]) > 0 ]
	
]

{ #category : #accessing }
GPAssertion >> individuals [
	^ individuals
]

{ #category : #initialization }
GPAssertion >> initialize [
	targetSelectors := OrderedCollection new.
	options := OrderedCollection new.
	metrics := Dictionary new.
	contextBlocks := OrderedCollection new.
	packageRegexs := OrderedCollection new.
	optionsDict := Dictionary new.
	directoryName := ''.
	results := OrderedCollection new.
	nameResultFile := 'result'.
	exportVisualization := false
]

{ #category : #'as yet unclassified' }
GPAssertion >> injectInto: tSelector given: originalMethod [
	| rbMethodNode |
	rbMethodNode := RBParser
		parseMethod: originalMethod sourceCode.
	rbMethodNode body addNodeFirst: (RBParser parseExpression: 'GPCounter addOccurrence: ''', tSelector, '''').
	targetClass compile: rbMethodNode printString notifying: nil.
]

{ #category : #accessing }
GPAssertion >> nameResultFile [ 
	^ (nameResultFile, '.csv') asFileReference 
]

{ #category : #accessing }
GPAssertion >> nameResultFile: string [
	self assert: (string isString and: [ string notEmpty ]).
	nameResultFile := string
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
	options := collection
	 
]

{ #category : #running }
GPAssertion >> run [
	| associations |
	self assert: targetClass isClass.
	self assert: testClass isClass.
	self targetSelectors ifEmpty: [ 
		individuals := Dictionary new.
		^ self ].
	GPCounter reset.
	associations := self getSelectorCandidates.
	individuals := Dictionary 
		newFromAssociations: (associations collect: [:assoc | 
			assoc key -> (self getBestIndividual: assoc value)]).
	self summaryOfEvolutionData.
	self exportEvolutionData.
	exportVisualization ifTrue: [ self exportEvolutionGraphic ] 
]

{ #category : #running }
GPAssertion >> runAllClasses [

	| selectedClasses packageClasses |
	self assert: packageRegexs notEmpty.
	packageClasses := packageRegexs flatCollect: [ :regex | 
		self selectPackageClasses: regex	
	].
	selectedClasses := self selectCandidateClasses: packageClasses.
	self runOn: selectedClasses given: packageClasses 
]

{ #category : #running }
GPAssertion >> runAllClassesExcept: collection [

	| packageClasses selectedClasses |
	packageClasses := packageRegexs flatCollect: [ :regex | 
		self selectPackageClasses: regex	
	].
	selectedClasses := (self selectCandidateClasses: packageClasses) reject: [:cls |
		collection includes: cls	
	].
	self runOn: selectedClasses given: packageClasses 
]

{ #category : #'as yet unclassified' }
GPAssertion >> runOn: classes given: packageClasses [
	classes do: [ :cl | 
		self targetClass: cl.
		self testClass: (self class environment at: cl name , 'Test').
		self options: self options.
		self addOptionClasses: (packageClasses collect: #name).
		self addOptionSelectors: (self collectTestingSelectors: packageClasses).
		(optionsDict at: #class ifAbsent: [ #() ]) 
			ifNotEmpty: [ self addOptionClasses: (optionsDict at: #class)].
		(optionsDict at: #selector ifAbsent: [ #() ] ) 
			ifNotEmpty: [ self addOptionSelectors: (optionsDict at: #selector) ].
		self run.
		individuals ifNotEmpty: [ self writeOnCsv ] ]
]

{ #category : #'as yet unclassified' }
GPAssertion >> selectCandidateClasses: classes [
	| names |
	names := classes collect: #name thenSelect: [:n | n endsWith: 'Test'].
	^ (classes reject: [ :c | c name endsWith: 'Test' ]) 
		select: [ :c | names includes: c name, 'Test' ].
						
]

{ #category : #'as yet unclassified' }
GPAssertion >> selectPackageClasses: regex [
	| packages |
	packages := RPackageOrganizer default packages select: [:p | regex match: p name asString ].
	^ ((packages 
			inject: #() 
			into: [:sum :el | sum, (el classes reject: #isTrait) asOrderedCollection ]) asSet) asOrderedCollection sort: [ :cl1 :cl2 | cl1 name < cl2 name ]
]

{ #category : #'as yet unclassified' }
GPAssertion >> summaryOfEvolutionData [
	| col nCalledMets nSuccMets nEvolMets nSuccEvolMets dictMessages numFailures |
	col := OrderedCollection new
		add: targetClass name;
		add: targetSelectors size;
		yourself.
	numFailures := 0.
	dictMessages := Dictionary new.
	nCalledMets := nSuccMets := nEvolMets := nSuccEvolMets := 0.
	individuals associationsDo: [ :assoc | | eng |
		eng := assoc value. 
		((metrics at: 'numCalls') at: assoc key) > 0 ifTrue: [ | bestFitness bestIndiv |
			nCalledMets := nCalledMets + 1.
			(eng population isEmpty or: [ eng population allSatisfy: #isNil ])
				ifFalse: [
					numFailures := eng configuration numberOfFailures. 
					bestFitness := eng logs first bestFitnessValue.
					bestIndiv := eng pickBestIndividual. 
					bestIndiv fitness == 0 ifTrue: [ nSuccMets := nSuccMets + 1 ].
					bestFitness > bestIndiv fitness ifTrue: [ 
						nEvolMets := nEvolMets + 1.
						bestIndiv fitness == 0 ifTrue: [ nSuccEvolMets := nSuccEvolMets + 1 ] ].
					self addDataOfNameSelectors: dictMessages given: bestIndiv ]
		]
	].
	col 
		add: numFailures;
		add: nCalledMets;
		add: nSuccMets; 
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
	self assert: aClass isClass.
	targetClass := aClass
]

{ #category : #'as yet unclassified' }
GPAssertion >> targetPackageRegexs: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	packageRegexs := collection
]

{ #category : #accessing }
GPAssertion >> targetSelectors [
	targetSelectors ifEmpty: [ 
		targetSelectors := targetClass selectors 
			select: [ :s | s numArgs > 0 ] ].
	^ targetSelectors 
]

{ #category : #accessing }
GPAssertion >> targetSelectors: collection [
	self assert: (collection isCollection and: [ collection notEmpty ]).
	targetSelectors := collection
	
]

{ #category : #accessing }
GPAssertion >> testClass: aClass [
	self assert: aClass isClass.
	testClass := aClass
]

{ #category : #'as yet unclassified' }
GPAssertion >> uninstallOf: originalMethod [
	self assert: targetClass isClass.
	targetClass methodDict at: originalMethod selector put: originalMethod 
]

{ #category : #writing }
GPAssertion >> writeOnCsv [
	| data  |
	self assert: individuals notEmpty.
	self assert: metrics notEmpty.
	data := (targetSelectors collect: [ :s | | best e |
		e := individuals at: s ifAbsent: [ nil ].
		[ best := e pickBestIndividual.
		OrderedCollection new 
			add: e configuration targetClass;
			add: s;
			add: e configuration numberOfFailures;
			add: ((metrics at: 'numErrors') at: s);
			add: ((metrics at: 'numCalls') at: s);
			add: best print;
			add: e logs first bestFitnessValue asString;
			add: best fitness asString;
			yourself ] on: Exception do: [ :err | nil ]] thenSelect: [:d | d notNil ]).
	
	data ifNotEmpty: [ 
		self filename writeStreamDo: [ :stream |
			(NeoCSVWriter on: stream)
				nextPut: #(Class Method TestErrors Errors Calls Result FstFitness LstFitness);
				nextPutAll: data;
				flush ] 
	]
]

{ #category : #writing }
GPAssertion >> writeResults [
	results ifNotEmpty: [ 
		self nameResultFile writeStreamDo: [ :stream |
			(NeoCSVWriter on: stream)
				nextPut: #(Class nMethods nTestErrors nCalledMeths nSatisfactoryAsserts nEvolvedAsserts nSatisfactoryEvols Message Message1 Satisfy Comparison And);
				nextPutAll: results;
				flush ] 
	]
]
