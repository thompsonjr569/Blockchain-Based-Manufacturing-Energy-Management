;; Facility Verification Contract
;; Validates legitimate production locations

(define-data-var admin principal tx-sender)

;; Map to store verified facilities
(define-map verified-facilities principal bool)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-already-verified (err u101))
(define-constant err-not-verified (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Add a facility to the verified list
(define-public (verify-facility (facility-address principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-none (map-get? verified-facilities facility-address)) err-already-verified)
    (ok (map-set verified-facilities facility-address true))))

;; Remove a facility from the verified list
(define-public (revoke-verification (facility-address principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (is-some (map-get? verified-facilities facility-address)) err-not-verified)
    (ok (map-delete verified-facilities facility-address))))

;; Check if a facility is verified
(define-read-only (is-verified (facility-address principal))
  (default-to false (map-get? verified-facilities facility-address)))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
