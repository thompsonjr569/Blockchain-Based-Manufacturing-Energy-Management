;; Savings Verification Contract
;; Measures reduced energy consumption

(define-data-var admin principal tx-sender)

;; Define savings record structure
(define-map savings-records
  { project-id: uint, period: uint }
  {
    actual-consumption-kwh: uint,
    baseline-consumption-kwh: uint,
    savings-kwh: uint,
    verification-date: uint,
    verified-by: principal
  }
)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-record-exists (err u106))
(define-constant err-record-not-found (err u107))
(define-constant err-invalid-savings (err u108))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Record energy savings for a project
(define-public (record-savings
    (project-id uint)
    (period uint)
    (actual-consumption-kwh uint)
    (baseline-consumption-kwh uint)
    (verification-date uint))
  (let (
    (savings-kwh (if (> baseline-consumption-kwh actual-consumption-kwh)
                    (- baseline-consumption-kwh actual-consumption-kwh)
                    u0))
    (record-key { project-id: project-id, period: period })
  )
    (begin
      (asserts! (is-admin) err-not-admin)
      (asserts! (is-none (map-get? savings-records record-key)) err-record-exists)
      (asserts! (<= actual-consumption-kwh baseline-consumption-kwh) err-invalid-savings)
      (ok (map-set savings-records
        record-key
        {
          actual-consumption-kwh: actual-consumption-kwh,
          baseline-consumption-kwh: baseline-consumption-kwh,
          savings-kwh: savings-kwh,
          verification-date: verification-date,
          verified-by: tx-sender
        }
      )))))

;; Get savings record
(define-read-only (get-savings-record (project-id uint) (period uint))
  (let ((record (map-get? savings-records { project-id: project-id, period: period })))
    (asserts! (is-some record) err-record-not-found)
    (ok (unwrap-panic record))))

;; Calculate total savings for a project across all periods
(define-read-only (get-total-project-savings (project-id uint))
  (ok u0)) ;; This is a placeholder - in a real implementation, we would iterate through all periods

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
