Class {
	#name : #GPMessage,
	#superclass : #GPExpression,
	#instVars : [
		'receiver',
		'message',
		'args'
	],
	#category : #'GeneticProgramming-AST'
}

{ #category : #'as yet unclassified' }
GPMessage class >> receiver: aReceiver message: aMessage [
	^ self new 
		receiver: aReceiver;
		message: aMessage
]

{ #category : #'as yet unclassified' }
GPMessage class >> receiver: aReceiver message: aMessage args: args [
	^ self new 
		receiver: aReceiver;
		message: aMessage;
		args: args
]

{ #category : #accessing }
GPMessage >> args [
	^ args
]

{ #category : #accessing }
GPMessage >> args: anObject [
	args := anObject
]

{ #category : #copying }
GPMessage >> deepCopy [ 
	^ self class new
	receiver: receiver deepCopy;
	message: message deepCopy;
	args: args deepCopy
	
]

{ #category : #'public access' }
GPMessage >> evaluate [ 
	^ (RBMessageNode new receiver: receiver value;
		selector: message name;
		arguments: (args collect: #value)) evaluate
]

{ #category : #initialization }
GPMessage >> initialize [ 	
	super initialize.
	args := #()
]

{ #category : #accessing }
GPMessage >> message [
	^ message
]

{ #category : #accessing }
GPMessage >> message: anObject [
	message := anObject
]

{ #category : #operations }
GPMessage >> mutate [

	| list |
	list := #( #mutateReceiver #mutateArgs ).
	^ self deepCopy perform: (list at: (random nextInteger: list size))
]

{ #category : #operations }
GPMessage >> mutateArgs [
	args ifNotEmpty: [ | index |
		index := random nextInt: args size.
		args at: index put: (args at: index) mutate ]
]

{ #category : #operations }
GPMessage >> mutateReceiver [
	receiver := receiver mutate
]

{ #category : #printing }
GPMessage >> printOn: stream [
	receiver printOn: stream.
	stream nextPut: Character space.
	message printOn: stream.
	args ifNotEmpty: [ stream nextPut: $ ].
	args do: [ :arg | arg printOn: stream ]
]

{ #category : #accessing }
GPMessage >> receiver [
	^ receiver
]

{ #category : #accessing }
GPMessage >> receiver: anObject [
	receiver := anObject
]

{ #category : #evaluating }
GPMessage >> value [ 
	^ RBMessageNode new receiver: receiver value;
		selector: message name;
		arguments: (args collect: #value)
]
