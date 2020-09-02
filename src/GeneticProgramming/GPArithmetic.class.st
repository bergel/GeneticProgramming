Class {
	#name : #GPArithmetic,
	#superclass : #GPAbstractNode,
	#instVars : [
		'val'
	],
	#category : #'GeneticProgramming-Arithmetic'
}

{ #category : #'public access' }
GPArithmetic >> evaluate [ 
	^ val evaluate
]

{ #category : #initialization }
GPArithmetic >> initialize [ 
	val := nil
]

{ #category : #accessing }
GPArithmetic >> number: number [
	| res |
	res := GPNode new.
	res type: (RBLiteralValueNode value: number).
	res printBlock: [ :children :context | res type formattedCode ].
	res evaluationBlock: [ :childre :context | res type evaluate ].
	^ res
]

{ #category : #'instance creation' }
GPArithmetic >> operate: operator [
	| res |
	res := GPNode new.
	res printBlock: [ :children :context |
		'(', (children first printUsing: context), operator, (children second printUsing: context), ')' ].
	res evaluationBlock: [ :children :context | | type |
		type := RBMessageNode new receiver: (children first evaluateUsing: context) asLiteralNode; selector: operator; arguments: {(children second evaluateUsing: context) asLiteralNode}.
		res type ifNil: [ res type: type ].
		type evaluate ].
	^ res
]

{ #category : #'instance creation' }
GPArithmetic >> operation: opMessage [
	val := opMessage 
]

{ #category : #'instance creation' }
GPArithmetic >> sum [
	| res |
	res := GPNode new.
	res printBlock: [ :children :context |
		'(', (children first printUsing: context), '+', (children second printUsing: context), ')' ].
	res evaluationBlock: [ :children :context | | type |
		type := RBMessageNode new receiver: (children first evaluateUsing: context) asLiteralNode; selector: #+; arguments: {(children second evaluateUsing: context) asLiteralNode}.
		res type ifNil: [ res type: type ].
		type evaluate ].
	^ res
]

{ #category : #accessing }
GPArithmetic >> val: expression [
	val := expression
]
