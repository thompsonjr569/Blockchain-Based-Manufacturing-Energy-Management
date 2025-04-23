;; Consumption Baseline Contract
;; Establishes standard energy usage for facilities

(define-data-var admin principal tx-sender)

;; Map to store energy baselines (in kWh) for each facility
(define-map energy-baselines principal uint)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-facility-not-found (err u103))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Set energy baseline for a facility
(define-public (set-baseline (facility-address principal) (baseline-kwh uint))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (map-set energy-baselines facility-address baseline-kwh))))

;; Get energy baseline for a facility
(define-read-only (get-baseline (facility-address principal))
  (let ((baseline (map-get? energy-baselines facility-address)))
    (asserts! (is-some baseline) err-facility-not-found)
    (ok (unwrap-panic baseline))))

;; Update energy baseline for a facility
(define-public (update-baseline (facility-address principal) (new-baseline-kwh uint))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? energy-baselines facility-address)) err-facility-not-found)
    (ok (map-set energy-baselines facility-address new-baseline-kwh))))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
