//
//  Coordinator.swift
//  MangaReader
//
//  Created by Juan on 30/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func removeChildCoordinator<T: Coordinator>(type: T.Type) {
        childCoordinators.removeAll { coordinator in
            coordinator is T
        }
    }
}
