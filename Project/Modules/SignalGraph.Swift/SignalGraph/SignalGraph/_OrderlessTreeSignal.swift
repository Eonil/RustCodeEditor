////
////  OrderlessTreeSignal.swift
////  SignalGraph
////
////  Created by Hoon H. on 2015/05/05.
////  Copyright (c) 2015 Eonil. All rights reserved.
////
//
//import Foundation
//
//enum OrderlessNodeSignal<K,V> {
//	typealias	Snapshot	=	OrderlessTree<K,V>
//	typealias	Transaction	=	CollectionTransaction<OrderlessTreeNodeLocation<K>,OrderlessNode<K,V>>
//	case Initiation	(snapshot	: Snapshot)
//	case Transition	(transaction: Transaction)
//	case Termination(snapshot	: Snapshot)
//}
//
//extension OrderlessNodeSignal: CollectionSignalType {
//	var initiation: Snapshot? {
//		get {
//			switch self {
//			case .Initiation(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//	var transition: Transaction? {
//		get {
//			switch self {
//			case .Transition(transaction: let s):	return	s
//			default:								return	nil
//			}
//		}
//	}
//	var termination: Snapshot? {
//		get {
//			switch self {
//			case .Termination(snapshot: let s):		return	s
//			default:								return	nil
//			}
//		}
//	}
//}
//
//
//
/////	Represents location of a tree node.
/////
/////	If `indexes == []`, it's a root node.
////	Otherwise, this designate a node at the index at the level.
//struct OrderlessTreeNodeLocation<K> {
//	var	indexes: [K]
//}
//
