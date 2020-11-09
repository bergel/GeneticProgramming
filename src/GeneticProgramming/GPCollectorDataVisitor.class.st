Class {
	#name : #GPCollectorDataVisitor,
	#superclass : #Object,
	#instVars : [
		'string'
	],
	#category : #'GeneticProgramming-Visitor'
}

{ #category : #initialization }
GPCollectorDataVisitor >> initialize [ 	
	string := ''
]

{ #category : #accessing }
GPCollectorDataVisitor >> string [
	^ string
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitAssignmentNode: assignmentNode [

	| res |
	self visitNode: assignmentNode variable.
	res := string, ' := '.
	self visitNode: assignmentNode value.
	res := res, string.
	string := res
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitLiteralNode: literal [
	string := literal value asString
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitLiteralValueNode: literal [

	string := literal value asString
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitMessageNode: messageNode [

	| res strArgs |
	self visitNode: messageNode receiver.
	res := string , ' ' , messageNode selector , ' '.
	strArgs := (messageNode arguments collect: [ :arg | 
		        self visitNode: arg.
		        string , ' ' ]).
	strArgs size == 1 ifTrue: [ strArgs := strArgs first ].
	string := res, strArgs asString
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitNode: node [

	node acceptVisitor: self
]

{ #category : #visiting }
GPCollectorDataVisitor >> visitVariableNode: variable [
	string := variable name
]
