#lang racket

(require db)

(provide init-database
         save
         get-data
         close-database)

(define db-conn #f)

(define (init-database)
  (define db-path (build-path (current-directory) "data.db"))
  (set! db-conn (sqlite3-connect #:database (path->string db-path)))

  (query-exec db-conn
              "CREATE TABLE IF NOT EXISTS avaliacoes (
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 visibilidade INTEGER,
                 compatibilidade INTEGER,
                 controle INTEGER,
                 consistencia INTEGER,
                 prevencao_erros INTEGER,
                 reconhecimento INTEGER,
                 flexibilidade INTEGER,
                 estetica INTEGER,
                 recuperacao_erros INTEGER,
                 ajuda_documentacao INTEGER
               )"))

(define (save dados-avaliacao)
  (query-exec db-conn
              "INSERT INTO avaliacoes 
               (visibilidade, compatibilidade, controle, consistencia, 
                prevencao_erros, reconhecimento, flexibilidade, estetica, 
                recuperacao_erros, ajuda_documentacao) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
              (hash-ref dados-avaliacao 'visibilidade)
              (hash-ref dados-avaliacao 'compatibilidade)
              (hash-ref dados-avaliacao 'controle)
              (hash-ref dados-avaliacao 'consistencia)
              (hash-ref dados-avaliacao 'prevencao_erros)
              (hash-ref dados-avaliacao 'reconhecimento)
              (hash-ref dados-avaliacao 'flexibilidade)
              (hash-ref dados-avaliacao 'estetica)
              (hash-ref dados-avaliacao 'recuperacao_erros)
              (hash-ref dados-avaliacao 'ajuda_documentacao)))

(define (get-data)
  (define total-avaliacoes
    (query-value db-conn "SELECT COUNT(*) FROM avaliacoes"))

  (define medias
    (if (> total-avaliacoes 0)
        (list
         (query-value db-conn "SELECT AVG(visibilidade) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(compatibilidade) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(controle) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(consistencia) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(prevencao_erros) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(reconhecimento) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(flexibilidade) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(estetica) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(recuperacao_erros) FROM avaliacoes")
         (query-value db-conn "SELECT AVG(ajuda_documentacao) FROM avaliacoes"))
        '(0 0 0 0 0 0 0 0 0 0)))

  (hash 'quantidade total-avaliacoes
        'medias medias))

(define (close-database)
  (when db-conn
    (disconnect db-conn)
    (set! db-conn #f)))
