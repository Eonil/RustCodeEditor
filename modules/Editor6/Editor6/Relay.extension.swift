//
//  Relay.extension.swift
//  Editor6
//
//  Created by Hoon H. on 2017/06/11.
//  Copyright © 2017 Eonil. All rights reserved.
//

import EonilSignet

extension Relay {
    ///
    /// Accepts optional source only if it is non-nil.
    ///
    func watch(_ source: Relay<T>?) {
        guard let source = source else { return }
        watch(source)
    }
}
