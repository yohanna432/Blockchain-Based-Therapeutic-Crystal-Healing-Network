;; ========================================
;; BLOCKCHAIN-BASED THERAPEUTIC CRYSTAL HEALING NETWORK
;; ========================================
;; A comprehensive system for coordinating gemstone therapy with crystal sharing,
;; energy healing session scheduling, practitioner certification management,
;; geological education, cultural practice respect, and therapeutic outcome documentation

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-not-found (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-balance (err u105))
(define-constant err-session-not-active (err u106))
(define-constant err-invalid-certification (err u107))
(define-constant err-sharing-not-available (err u108))

;; Data Variables
(define-data-var next-crystal-id uint u1)
(define-data-var next-session-id uint u1)
(define-data-var next-request-id uint u1)
(define-data-var next-resource-id uint u1)
(define-data-var certification-fee uint u1000000) ;; 1 STX in microSTX
(define-data-var platform-fee-rate uint u250) ;; 2.5% (250/10000)

;; Crystal Types with Geological and Cultural Information
(define-map crystal-types
  { type-id: uint }
  {
    name: (string-ascii 50),
    geological-info: (string-utf8 500),
    cultural-significance: (string-utf8 500),
    therapeutic-properties: (string-utf8 500),
    vibrational-frequency: uint,
    chakra-alignment: (string-ascii 20),
    mineral-hardness: uint, ;; Mohs scale 1-10
    crystal-system: (string-ascii 30),
    active: bool
  }
)

;; Individual Crystal Registry with Stewardship Tracking
(define-map crystals
  { crystal-id: uint }
  {
    owner: principal,
    type-id: uint,
    condition: (string-ascii 20), ;; excellent, good, fair, poor
    acquisition-date: uint,
    last-cleansing: uint,
    sharing-available: bool,
    location: (string-ascii 100),
    certification-verified: bool,
    energy-charge-level: uint, ;; 1-100
    ethical-sourcing-verified: bool,
    stewardship-notes: (string-utf8 300)
  }
)

;; Practitioner Certifications with Cultural Training
(define-map practitioners
  { practitioner: principal }
  {
    certification-level: uint, ;; 1=basic, 2=intermediate, 3=advanced, 4=master
    specializations: (list 10 uint), ;; crystal type IDs
    certification-date: uint,
    expiry-date: uint,
    sessions-completed: uint,
    rating: uint, ;; 1-100
    active: bool,
    cultural-training-completed: bool,
    geological-education-completed: bool,
    ethics-training-completed: bool
  }
)

;; Healing Sessions with Comprehensive Tracking
(define-map healing-sessions
  { session-id: uint }
  {
    practitioner: principal,
    client: principal,
    crystals-used: (list 20 uint),
    session-type: (string-ascii 30),
    start-time: uint,
    duration-minutes: uint,
    location: (string-ascii 100),
    fee: uint,
    status: (string-ascii 20), ;; scheduled, active, completed, cancelled
    outcome-documented: bool,
    cultural-protocols-followed: bool
  }
)

;; Therapeutic Outcome Documentation
(define-map session-outcomes
  { session-id: uint }
  {
    energy-levels-before: (list 7 uint), ;; 7 chakras, levels 1-100
    energy-levels-after: (list 7 uint),
    crystals-effectiveness: (list 20 uint), ;; effectiveness rating per crystal 1-100
    vibrational-alignment: (list 7 uint), ;; chakra-crystal alignment scores
    client-feedback: (string-utf8 1000),
    practitioner-notes: (string-utf8 1000),
    follow-up-recommended: bool,
    cultural-respect-maintained: bool,
    documented-at: uint
  }
)

;; Crystal Sharing Network
(define-map sharing-requests
  { request-id: uint }
  {
    requester: principal,
    crystal-id: uint,
    purpose: (string-utf8 200),
    duration-days: uint,
    collateral-amount: uint,
    status: (string-ascii 20), ;; pending, approved, active, returned, disputed
    created-at: uint,
    approved-at: uint,
    return-due-date: uint
  }
)

;; Educational Resources with Cultural Sensitivity
(define-map educational-resources
  { resource-id: uint }
  {
    title: (string-utf8 200),
    content-type: (string-ascii 20), ;; geological, cultural, therapeutic, ethics
    content-hash: (string-ascii 64), ;; IPFS hash
    contributor: principal,
    verified: bool,
    access-level: uint, ;; 0=public, 1=practitioners, 2=advanced, 3=masters
    cultural-sensitivity-reviewed: bool
  }
)

;; Cultural Practice Guidelines
(define-map cultural-guidelines
  { guideline-id: uint }
  {
    culture-name: (string-ascii 50),
    practices: (string-utf8 800),
    restrictions: (string-utf8 500),
    respect-protocols: (string-utf8 500),
    contributor: principal,
    verified: bool
  }
)

;; Read-Only Functions

(define-read-only (get-crystal (crystal-id uint))
  (map-get? crystals { crystal-id: crystal-id })
)

(define-read-only (get-crystal-type (type-id uint))
  (map-get? crystal-types { type-id: type-id })
)

(define-read-only (get-practitioner (practitioner principal))
  (map-get? practitioners { practitioner: practitioner })
)

(define-read-only (get-session (session-id uint))
  (map-get? healing-sessions { session-id: session-id })
)

(define-read-only (get-session-outcome (session-id uint))
  (map-get? session-outcomes { session-id: session-id })
)

(define-read-only (get-sharing-request (request-id uint))
  (map-get? sharing-requests { request-id: request-id })
)

(define-read-only (get-educational-resource (resource-id uint))
  (map-get? educational-resources { resource-id: resource-id })
)

(define-read-only (is-certified-practitioner (practitioner principal))
  (match (map-get? practitioners { practitioner: practitioner })
    some-cert (and
                (get active some-cert)
                (> (get expiry-date some-cert) stacks-block-height)
                (get cultural-training-completed some-cert))
    false
  )
)

(define-read-only (calculate-session-fee (duration-minutes uint) (crystal-count uint))
  (let (
    (base-fee (* duration-minutes u50)) ;; 50 microSTX per minute
    (crystal-fee (* crystal-count u100000)) ;; 0.1 STX per crystal
    (total-fee (+ base-fee crystal-fee))
  )
    (+ total-fee (/ (* total-fee (var-get platform-fee-rate)) u10000))
  )
)

(define-read-only (get-platform-statistics)
  {
    total-crystals: (- (var-get next-crystal-id) u1),
    total-sessions: (- (var-get next-session-id) u1),
    total-sharing-requests: (- (var-get next-request-id) u1),
    total-resources: (- (var-get next-resource-id) u1),
    certification-fee: (var-get certification-fee),
    platform-fee-rate: (var-get platform-fee-rate)
  }
)

;; Administrative Functions

(define-public (initialize-crystal-database)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; Initialize fundamental crystal types with comprehensive data
    (unwrap-panic (add-crystal-type u1 "Clear Quartz"
           u"Silicon dioxide (SiO2), hexagonal crystal system. Forms in hydrothermal environments at 573C. Piezoelectric properties."
           u"Known as the 'master healer' in many traditions. Sacred to Aboriginal Australians, used in Atlantean legends, central to modern New Age practices."
           u"Amplifies energy and thought, aids concentration and memory. Balances all chakras. Enhances spiritual growth and clarity."
           u7830 "Crown" u7 "Hexagonal"))
    (unwrap-panic (add-crystal-type u2 "Amethyst"
           u"Silicon dioxide with iron inclusions creating purple color. Trigonal crystal system. Formed in volcanic rock cavities."
           u"Sacred stone in Christianity, Buddhism, and ancient Greece. Associated with sobriety, spiritual wisdom, and protection from negative energy."
           u"Promotes calm, reduces stress and anxiety. Enhances intuition, spiritual awareness, and meditation. Supports addiction recovery."
           u6420 "Third Eye" u7 "Trigonal"))
    (unwrap-panic (add-crystal-type u3 "Rose Quartz"
           u"Silicon dioxide with titanium, iron, or manganese inclusions. Trigonal system. Forms in pegmatite deposits."
           u"Stone of unconditional love across cultures. Used in Egyptian and Roman beauty rituals. Central to heart chakra work."
           u"Promotes self-love, emotional healing, compassion. Opens heart chakra, attracts love, heals relationship trauma."
           u5280 "Heart" u7 "Trigonal"))
    (ok true)
  )
)

(define-private (add-crystal-type
  (type-id uint)
  (name (string-ascii 50))
  (geological-info (string-utf8 500))
  (cultural-significance (string-utf8 500))
  (therapeutic-properties (string-utf8 500))
  (vibrational-frequency uint)
  (chakra-alignment (string-ascii 20))
  (mineral-hardness uint)
  (crystal-system (string-ascii 30)))
  (begin
    (map-set crystal-types { type-id: type-id }
      {
        name: name,
        geological-info: geological-info,
        cultural-significance: cultural-significance,
        therapeutic-properties: therapeutic-properties,
        vibrational-frequency: vibrational-frequency,
        chakra-alignment: chakra-alignment,
        mineral-hardness: mineral-hardness,
        crystal-system: crystal-system,
        active: true
      })
    (ok true)
  )
)

;; Crystal Management Functions

(define-public (register-crystal
  (type-id uint)
  (condition (string-ascii 20))
  (location (string-ascii 100))
  (ethical-sourcing-verified bool)
  (stewardship-notes (string-utf8 300)))
  (let (
    (crystal-id (var-get next-crystal-id))
  )
    (asserts! (is-some (map-get? crystal-types { type-id: type-id })) err-not-found)
    (map-set crystals { crystal-id: crystal-id }
      {
        owner: tx-sender,
        type-id: type-id,
        condition: condition,
        acquisition-date: stacks-block-height,
        last-cleansing: stacks-block-height,
        sharing-available: false,
        location: location,
        certification-verified: false,
        energy-charge-level: u80,
        ethical-sourcing-verified: ethical-sourcing-verified,
        stewardship-notes: stewardship-notes
      })
    (var-set next-crystal-id (+ crystal-id u1))
    (ok crystal-id)
  )
)

(define-public (update-crystal-energy (crystal-id uint) (energy-level uint))
  (let (
    (crystal-data (unwrap! (map-get? crystals { crystal-id: crystal-id }) err-not-found))
  )
    (asserts! (is-eq (get owner crystal-data) tx-sender) err-unauthorized)
    (asserts! (and (>= energy-level u1) (<= energy-level u100)) err-invalid-input)
    (map-set crystals { crystal-id: crystal-id }
      (merge crystal-data {
        energy-charge-level: energy-level,
        last-cleansing: stacks-block-height
      }))
    (ok true)
  )
)

(define-public (set-crystal-sharing (crystal-id uint) (available bool))
  (let (
    (crystal-data (unwrap! (map-get? crystals { crystal-id: crystal-id }) err-not-found))
  )
    (asserts! (is-eq (get owner crystal-data) tx-sender) err-unauthorized)
    (map-set crystals { crystal-id: crystal-id }
      (merge crystal-data { sharing-available: available }))
    (ok true)
  )
)

(define-public (update-stewardship-notes (crystal-id uint) (notes (string-utf8 300)))
  (let (
    (crystal-data (unwrap! (map-get? crystals { crystal-id: crystal-id }) err-not-found))
  )
    (asserts! (is-eq (get owner crystal-data) tx-sender) err-unauthorized)
    (map-set crystals { crystal-id: crystal-id }
      (merge crystal-data { stewardship-notes: notes }))
    (ok true)
  )
)

;; Practitioner Certification Functions

(define-public (apply-for-certification
  (level uint)
  (specializations (list 10 uint))
  (cultural-training-completed bool)
  (geological-education-completed bool)
  (ethics-training-completed bool))
  (begin
    (asserts! (and (>= level u1) (<= level u4)) err-invalid-input)
    (asserts! (is-none (map-get? practitioners { practitioner: tx-sender })) err-already-exists)
    (asserts! cultural-training-completed err-invalid-input) ;; Required for all levels
    (try! (stx-transfer? (var-get certification-fee) tx-sender contract-owner))
    (map-set practitioners { practitioner: tx-sender }
      {
        certification-level: level,
        specializations: specializations,
        certification-date: stacks-block-height,
        expiry-date: (+ stacks-block-height u52560), ;; ~1 year in blocks
        sessions-completed: u0,
        rating: u50, ;; Starting rating
        active: true,
        cultural-training-completed: cultural-training-completed,
        geological-education-completed: geological-education-completed,
        ethics-training-completed: ethics-training-completed
      })
    (ok true)
  )
)

(define-public (renew-certification)
  (let (
    (practitioner-data (unwrap! (map-get? practitioners { practitioner: tx-sender }) err-not-found))
  )
    (try! (stx-transfer? (var-get certification-fee) tx-sender contract-owner))
    (map-set practitioners { practitioner: tx-sender }
      (merge practitioner-data {
        certification-date: stacks-block-height,
        expiry-date: (+ stacks-block-height u52560)
      }))
    (ok true)
  )
)

;; Session Management Functions

(define-public (schedule-session
  (client principal)
  (crystals-used (list 20 uint))
  (session-type (string-ascii 30))
  (duration-minutes uint)
  (location (string-ascii 100))
  (cultural-protocols-followed bool))
  (let (
    (session-id (var-get next-session-id))
    (session-fee (calculate-session-fee duration-minutes (len crystals-used)))
  )
    (asserts! (is-certified-practitioner tx-sender) err-invalid-certification)
    (asserts! (> duration-minutes u0) err-invalid-input)
    (map-set healing-sessions { session-id: session-id }
      {
        practitioner: tx-sender,
        client: client,
        crystals-used: crystals-used,
        session-type: session-type,
        start-time: stacks-block-height,
        duration-minutes: duration-minutes,
        location: location,
        fee: session-fee,
        status: "scheduled",
        outcome-documented: false,
        cultural-protocols-followed: cultural-protocols-followed
      })
    (var-set next-session-id (+ session-id u1))
    (ok session-id)
  )
)

(define-public (start-session (session-id uint))
  (let (
    (session-data (unwrap! (map-get? healing-sessions { session-id: session-id }) err-not-found))
  )
    (asserts! (is-eq (get practitioner session-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status session-data) "scheduled") err-invalid-input)
    (map-set healing-sessions { session-id: session-id }
      (merge session-data {
        status: "active",
        start-time: stacks-block-height
      }))
    (ok true)
  )
)

(define-public (complete-session (session-id uint))
  (let (
    (session-data (unwrap! (map-get? healing-sessions { session-id: session-id }) err-not-found))
    (practitioner-data (unwrap! (map-get? practitioners { practitioner: tx-sender }) err-not-found))
  )
    (asserts! (is-eq (get practitioner session-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status session-data) "active") err-session-not-active)
    (map-set healing-sessions { session-id: session-id }
      (merge session-data { status: "completed" }))
    ;; Update practitioner statistics
    (map-set practitioners { practitioner: tx-sender }
      (merge practitioner-data {
        sessions-completed: (+ (get sessions-completed practitioner-data) u1)
      }))
    (ok true)
  )
)

;; Therapeutic Outcome Documentation

(define-public (document-session-outcome
  (session-id uint)
  (energy-before (list 7 uint))
  (energy-after (list 7 uint))
  (crystals-effectiveness (list 20 uint))
  (vibrational-alignment (list 7 uint))
  (client-feedback (string-utf8 1000))
  (practitioner-notes (string-utf8 1000))
  (follow-up-recommended bool)
  (cultural-respect-maintained bool))
  (let (
    (session-data (unwrap! (map-get? healing-sessions { session-id: session-id }) err-not-found))
  )
    (asserts! (is-eq (get practitioner session-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status session-data) "completed") err-invalid-input)
    (map-set session-outcomes { session-id: session-id }
      {
        energy-levels-before: energy-before,
        energy-levels-after: energy-after,
        crystals-effectiveness: crystals-effectiveness,
        vibrational-alignment: vibrational-alignment,
        client-feedback: client-feedback,
        practitioner-notes: practitioner-notes,
        follow-up-recommended: follow-up-recommended,
        cultural-respect-maintained: cultural-respect-maintained,
        documented-at: stacks-block-height
      })
    (map-set healing-sessions { session-id: session-id }
      (merge session-data { outcome-documented: true }))
    (ok true)
  )
)

;; Crystal Sharing Network Functions

(define-public (request-crystal-sharing
  (crystal-id uint)
  (purpose (string-utf8 200))
  (duration-days uint)
  (collateral-amount uint))
  (let (
    (request-id (var-get next-request-id))
    (crystal-data (unwrap! (map-get? crystals { crystal-id: crystal-id }) err-not-found))
  )
    (asserts! (get sharing-available crystal-data) err-sharing-not-available)
    (asserts! (> duration-days u0) err-invalid-input)
    (asserts! (> collateral-amount u0) err-invalid-input)
    (try! (stx-transfer? collateral-amount tx-sender (as-contract tx-sender)))
    (map-set sharing-requests { request-id: request-id }
      {
        requester: tx-sender,
        crystal-id: crystal-id,
        purpose: purpose,
        duration-days: duration-days,
        collateral-amount: collateral-amount,
        status: "pending",
        created-at: stacks-block-height,
        approved-at: u0,
        return-due-date: u0
      })
    (var-set next-request-id (+ request-id u1))
    (ok request-id)
  )
)

(define-public (approve-sharing-request (request-id uint))
  (let (
    (request-data (unwrap! (map-get? sharing-requests { request-id: request-id }) err-not-found))
    (crystal-data (unwrap! (map-get? crystals { crystal-id: (get crystal-id request-data) }) err-not-found))
    (return-due (+ stacks-block-height (* (get duration-days request-data) u144))) ;; ~144 blocks per day
  )
    (asserts! (is-eq (get owner crystal-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status request-data) "pending") err-invalid-input)
    (map-set sharing-requests { request-id: request-id }
      (merge request-data {
        status: "active",
        approved-at: stacks-block-height,
        return-due-date: return-due
      }))
    (ok true)
  )
)

(define-public (return-shared-crystal (request-id uint))
  (let (
    (request-data (unwrap! (map-get? sharing-requests { request-id: request-id }) err-not-found))
  )
    (asserts! (is-eq (get requester request-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status request-data) "active") err-invalid-input)
    (try! (as-contract (stx-transfer? (get collateral-amount request-data)
                        tx-sender (get requester request-data))))
    (map-set sharing-requests { request-id: request-id }
      (merge request-data { status: "returned" }))
    (ok true)
  )
)

;; Educational Resource Management

(define-public (contribute-educational-resource
  (title (string-utf8 200))
  (content-type (string-ascii 20))
  (content-hash (string-ascii 64))
  (access-level uint)
  (cultural-sensitivity-reviewed bool))
  (let (
    (resource-id (var-get next-resource-id))
  )
    (asserts! (or (is-certified-practitioner tx-sender)
                  (is-eq tx-sender contract-owner)) err-unauthorized)
    (asserts! (<= access-level u3) err-invalid-input)
    (map-set educational-resources { resource-id: resource-id }
      {
        title: title,
        content-type: content-type,
        content-hash: content-hash,
        contributor: tx-sender,
        verified: false,
        access-level: access-level,
        cultural-sensitivity-reviewed: cultural-sensitivity-reviewed
      })
    (var-set next-resource-id (+ resource-id u1))
    (ok resource-id)
  )
)

(define-public (verify-educational-resource (resource-id uint))
  (let (
    (resource-data (unwrap! (map-get? educational-resources { resource-id: resource-id }) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set educational-resources { resource-id: resource-id }
      (merge resource-data { verified: true }))
    (ok true)
  )
)

;; Payment Functions

(define-public (pay-session-fee (session-id uint))
  (let (
    (session-data (unwrap! (map-get? healing-sessions { session-id: session-id }) err-not-found))
    (fee (get fee session-data))
    (platform-fee (/ (* fee (var-get platform-fee-rate)) u10000))
    (practitioner-fee (- fee platform-fee))
  )
    (asserts! (is-eq (get client session-data) tx-sender) err-unauthorized)
    (asserts! (is-eq (get status session-data) "completed") err-invalid-input)
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    (try! (stx-transfer? practitioner-fee tx-sender (get practitioner session-data)))
    (ok true)
  )
)

;; Owner Functions

(define-public (set-certification-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set certification-fee new-fee)
    (ok true)
  )
)

(define-public (set-platform-fee-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-rate u1000) err-invalid-input) ;; Max 10%
    (var-set platform-fee-rate new-rate)
    (ok true)
  )
)
