//
//  CoordinatorTests.swift
//  GSCoreTests
//
//  Created by David Lima on 23/12/19.
//  Copyright © 2019 David Lima. All rights reserved.
//

import XCTest
@testable import GSCore

class CoordinatorTests: XCTestCase {

    var coordinator: Coordinator!
    var navigation: UINavigationController!
    
    override func setUp() {
        self.coordinator = Coordinator()
        self.navigation = UINavigationController()
    }

    override func tearDown() {
        
    }
    
    // MARK: - Add and Remove
    func testCoordinatorAddIncreaseInstanceCount() {
        let child = Coordinator()
        let countBefore = coordinator.childCoordinators.count
        coordinator.addChildCoordinator(child)
        let countAfter = coordinator.childCoordinators.count
        XCTAssert(countBefore < countAfter)
    }
    
    func testCoordinatorRemoveDecreaseInstanceCount() {
        let child = Coordinator()
        coordinator.addChildCoordinator(child)
        let countBefore = coordinator.childCoordinators.count
        coordinator.removeChildCoordinator(child)
        let countAfter = coordinator.childCoordinators.count
        XCTAssert(countBefore > countAfter)
    }
    
    func testCoordinatorRemoveAllDecreaseInstanceCount() {
        let child = Coordinator()
        coordinator.addChildCoordinator(child)
        let countBefore = coordinator.childCoordinators.count
        coordinator.removeAllChildCoordinators()
        let countAfter = coordinator.childCoordinators.count
        XCTAssert(countBefore > countAfter)
    }
    
    func testCoordinatorRemoveTypedDecreaseInstanceCount() {
        let child = CoordinatorA()
        coordinator.addChildCoordinator(child)
        let countBefore = coordinator.childCoordinators.count
        coordinator.removeAllChildCoordinatorsWith(type: CoordinatorA.self)
        let countAfter = coordinator.childCoordinators.count
        XCTAssert(countBefore > countAfter)
    }
}
