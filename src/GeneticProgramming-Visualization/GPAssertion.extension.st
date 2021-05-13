Extension { #name : #GPAssertion }

{ #category : #'*GeneticProgramming-Visualization' }
GPAssertion >> exportEvolutionGraphic [ 
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
				nextPutAll: '.svg' ].
		RSSVGExporter  new
			canvas: eng visualize;
			exportToFile: filename asFileReference
	]
]
