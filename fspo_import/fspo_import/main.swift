//
//  main.swift
//  fspo_import
//
//  Created by Кирилл on 29.04.2021.
//

import Foundation
URLSession.shared.configuration.requestCachePolicy = .returnCacheDataDontLoad


try SubgroupsImport().keepAlive()
