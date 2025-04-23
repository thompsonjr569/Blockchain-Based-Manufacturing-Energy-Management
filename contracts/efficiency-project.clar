;; Efficiency Project Contract
;; Tracks implemented conservation measures

(define-data-var admin principal tx-sender)

;; Define project structure
(define-map projects
  { project-id: uint }
  {
    facility: principal,
    name: (string-ascii 100),
    description: (string-ascii 500),
    start-date: uint,
    end-date: uint,
    status: (string-ascii 20),
    expected-savings-kwh: uint
  }
)

;; Counter for project IDs
(define-data-var project-id-counter uint u0)

;; Error codes
(define-constant err-not-admin (err u100))
(define-constant err-project-not-found (err u104))
(define-constant err-invalid-status (err u105))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Create a new efficiency project
(define-public (create-project
    (facility principal)
    (name (string-ascii 100))
    (description (string-ascii 500))
    (start-date uint)
    (end-date uint)
    (expected-savings-kwh uint))
  (let ((new-id (+ (var-get project-id-counter) u1)))
    (begin
      (asserts! (is-admin) err-not-admin)
      (var-set project-id-counter new-id)
      (ok (map-set projects
        { project-id: new-id }
        {
          facility: facility,
          name: name,
          description: description,
          start-date: start-date,
          end-date: end-date,
          status: "planned",
          expected-savings-kwh: expected-savings-kwh
        }
      )))))

;; Get project details
(define-read-only (get-project (project-id uint))
  (let ((project (map-get? projects { project-id: project-id })))
    (asserts! (is-some project) err-project-not-found)
    (ok (unwrap-panic project))))

;; Update project status
(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
  (let ((project (map-get? projects { project-id: project-id })))
    (begin
      (asserts! (is-admin) err-not-admin)
      (asserts! (is-some project) err-project-not-found)
      (asserts! (or
                  (is-eq new-status "planned")
                  (is-eq new-status "in-progress")
                  (is-eq new-status "completed")
                  (is-eq new-status "cancelled"))
                err-invalid-status)
      (ok (map-set projects
        { project-id: project-id }
        (merge (unwrap-panic project) { status: new-status })
      )))))

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (ok (var-set admin new-admin))))
