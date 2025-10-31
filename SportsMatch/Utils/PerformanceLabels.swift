//
//  PerformanceLabels.swift
//  SportsMatch
//
//  Created by Assistant on 31/10/2025.
//

import Foundation

func labelForMetric(_ key: PerformanceMetricKey, sport: Sport?) -> String {
    switch key {
    case .availabilityMinutes:
        return "Minutes jouées 28j"
    case .matchesPlayed:
        return "Matchs/épreuves 28j"
    case .decisiveActions:
        switch sport {
        case .some(.football): return "Buts + passes décisives 28j"
        case .some(.rugby): return "Essais + passes décisives 28j"
        case .some(.hockey): return "Buts + assists 28j"
        case .some(.basketball): return "Points + assists 28j"
        case .some(.handball): return "Buts + passes 28j"
        case .some(.volleyball): return "Aces + blocks 28j"
        case .some(.tennis): return "Victoires/sets gagnants 28j"
        case .some(.badminton): return "Victoires/sets gagnants 28j"
        case .some(.tableTennis): return "Victoires/manches gagnées 28j"
        case .some(.swimming): return "Records/chrono améliorés 28j"
        case .some(.athletics): return "PR/records perso 28j"
        case .some(.cycling): return "PR/segments gagnés 28j"
        case .some(.martialArts): return "Victoires 28j"
        case .some(.baseball): return "Hits + RBIs 28j"
        case .some(.golf): return "Scores sous le par 28j"
        case .none: return "Actions décisives 28j"
        }
    case .maxSpeedKmh:
        switch sport {
        case .some(.football): return "Vitesse max (km/h)"
        case .some(.rugby): return "Vitesse max (km/h)"
        case .some(.hockey): return "Vitesse max (km/h)"
        case .some(.basketball): return "Vitesse max (km/h)"
        case .some(.handball): return "Vitesse max (km/h)"
        case .some(.volleyball): return "Perf clé (ex: détente/serv.)"
        case .some(.tennis): return "Perf clé (ex: vitesse service)"
        case .some(.badminton): return "Perf clé (ex: smash speed)"
        case .some(.tableTennis): return "Perf clé (ex: efficacité)"
        case .some(.swimming): return "Perf clé (ex: meilleur chrono)"
        case .some(.athletics): return "Perf clé (ex: meilleur chrono)"
        case .some(.cycling): return "Perf clé (ex: meilleure puissance)"
        case .some(.martialArts): return "Perf clé (ex: ippon/KO rate)"
        case .some(.baseball): return "Perf clé (ex: bat speed)"
        case .some(.golf): return "Perf clé (ex: club speed)"
        case .none: return "Vitesse max / Perf clé"
        }
    case .trainingVolumeMinPerWeek:
        return "Volume entraînement (min/sem)"
    case .penaltiesEvents:
        switch sport {
        case .some(.football): return "Cartons/fautes 28j"
        case .some(.rugby): return "Pénalités/fautes 28j"
        case .some(.hockey): return "Pénalités/expulsions 28j"
        case .some(.basketball): return "Fautes/balles perdues 28j"
        case .some(.handball): return "Exclusions/fautes 28j"
        case .some(.volleyball): return "Fautes directes 28j"
        case .some(.tennis): return "Pénalités/double fautes 28j"
        case .some(.badminton): return "Fautes de service 28j"
        case .some(.tableTennis): return "Fautes directes 28j"
        case .some(.swimming): return "Disqualifications 28j"
        case .some(.athletics): return "Faux départs/DSQ 28j"
        case .some(.cycling): return "Pénalités/DSQ 28j"
        case .some(.martialArts): return "Pénalités/shido 28j"
        case .some(.baseball): return "Erreurs (E) 28j"
        case .some(.golf): return "Pénalités 28j"
        case .none: return "Pénalités/fautes 28j"
        }
    }
}


