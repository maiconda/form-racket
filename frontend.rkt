#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/dispatch
         "backend.rkt"
         racket/format)

(provide start-servlet)

(define-values (dispatch url->request)
  (dispatch-rules
   [("") home-page]
   [("form") form-page]
   [("chart") chart-page]
   [("submit") #:method "post" submit-evaluation]
   [else not-found-page]))

(define (start-servlet request)
  (printf "Request URI: ~a\n" (request-uri request))
  (printf "Request method: ~a\n" (request-method request))
  (printf "URL path: ~a\n" (map path/param-path (url-path (request-uri request))))
  
  (with-handlers ([exn:fail? (lambda (e)
                              (printf "Dispatch error: ~a\n" (exn-message e))
                              (not-found-page))])
    (dispatch request)))

(define (chart-page request)
  (let ([stats (get-evaluation-stats)])
    (response/xexpr
     `(html
       (head
        (title "DrRacket Usability Evaluation"))
       (body
        (div ((class "container"))
                  (div ((class "stats-summary"))
                       (p ,(format "Total evaluations: ~a" (hash-ref stats 'quantidade)))
                       (p ,(format "Average overall rating: ~a/10" 
                                  (let ([avg (/ (apply + (hash-ref stats 'medias)) 
                                               (length (hash-ref stats 'medias)))])
                                    (number->string (/ (round (* avg 10)) 10)))))))
             (div ((class "cta-button"))
                  (a ((href "/") (class "button")) "Voltar para tela inicial")))))))

(define (home-page request)
  (let ([stats (get-evaluation-stats)])
    (response/xexpr
     `(html
       (head
        (title "DrRacket Usability Evaluation"))
       (body
        (div ((class "container"))
 
                  (div ((class "stats-summary"))
                       (p ,(format "Total evaluations: ~a" (hash-ref stats 'quantidade)))
                       (p ,(format "Average overall rating: ~a/10" 
                                  (let ([avg (/ (apply + (hash-ref stats 'medias)) 
                                               (length (hash-ref stats 'medias)))])
                                    (number->string (/ (round (* avg 10)) 10)))))))
             
             (div ((class "cta-button"))
                  (a ((href "form") (class "button")) "Avaliar DrRacket")))))))

(define (form-page request)
  (response/xexpr
   `(html
     (head
      (title "Evaluate DrRacket - Usability Evaluation"))
     (body
      (div ((class "container"))
           (h1 "Evaluate DrRacket")
           (p "Please rate DrRacket based on Nielsen's 10 usability heuristics. Click on the dots to select your rating (1-10).")
           
           (form ((action "/submit") (method "post") (id "evaluation-form"))
                 
                 (div ((class "evaluation-section"))
                      (h2 "1. Visibilidade do status do sistema")
                      (p "O DrRacket informa claramente quando está processando ou executando um código? É fácil perceber se há algum erro durante a execução? O feedback das ações é imediato e visível?")
                      (input ((type "number") (name "visibilidade") (id "visibilidade-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "2. Compatibilidade entre o sistema e o mundo real")
                      (p "As mensagens de erro ou de sistema são compreensíveis por usuários não técnicos? Os termos e expressões usados no ambiente refletem a linguagem comum ao usuário?")
                      (input ((type "number") (name "compatibilidade") (id "compatibilidade-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "3. Controle e liberdade do usuário")
                      (p "É fácil desfazer ou refazer ações no DrRacket? Você sente que tem controle sobre as ações realizadas no ambiente (rodar, parar, editar)?")
                      (input ((type "number") (name "controle") (id "controle-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "4. Consistência e padrões")
                      (p "A interface do DrRacket mantém padrões consistentes? Funções semelhantes são representadas de forma semelhante (visual e funcionalmente)?")
                      (input ((type "number") (name "consistencia") (id "consistencia-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "5. Prevenção de erros")
                      (p "O software ajuda a evitar erros antes que eles ocorram? Há alertas ou avisos antes de ações potencialmente destrutivas?")
                      (input ((type "number") (name "prevencao_erros") (id "prevencao_erros-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "6. Reconhecimento em vez de memorização")
                      (p "O ambiente facilita o uso sem exigir que o usuário memorize comandos? Os menus e botões são autoexplicativos e de fácil acesso?")
                      (input ((type "number") (name "reconhecimento") (id "reconhecimento-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "7. Flexibilidade e eficiência de uso")
                      (p "Usuários experientes podem utilizar atalhos ou recursos avançados para aumentar a produtividade? O ambiente se adapta bem tanto a iniciantes quanto a usuários mais experientes?")
                      (input ((type "number") (name "flexibilidade") (id "flexibilidade-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "8. Estética e design minimalista")
                      (p "A interface é limpa e sem elementos desnecessários? O design facilita o foco nas tarefas principais, como escrever e rodar código?")
                      (input ((type "number") (name "estetica") (id "estetica-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "9. Ajudar os usuários a reconhecer, diagnosticar e recuperar erros")
                      (p "As mensagens de erro são claras e ajudam a entender o que precisa ser corrigido? É fácil identificar o tipo de erro e encontrar sua localização no código?")
                      (input ((type "number") (name "recuperacao_erros") (id "recuperacao_erros-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "evaluation-section"))
                      (h2 "10. Ajuda e documentação")
                      (p "A ajuda integrada (como documentação ou dicas) é útil e de fácil acesso? Você consegue encontrar rapidamente a resposta para uma dúvida dentro do próprio DrRacket?")
                      (input ((type "number") (name "recuperacao_erros") (id "recuperacao_erros-value") (value "1")(min "1")(max "10"))))
                 
                 (div ((class "form-actions"))
                      (button ((type "submit") (class "button")) "Submit Evaluation"))))))))

(define (submit-evaluation request)
  (define bindings
    (request-bindings/raw request))
  
  (define evaluation-data
    (make-hash))
  
  (define (extract-value field-name)
    (define field-bytes (string->bytes/utf-8 (symbol->string field-name)))
    (define binding (bindings-assq field-bytes bindings))
    (if binding
        (string->number (bytes->string/utf-8 (binding:form-value binding)))
        0))
  
  (hash-set! evaluation-data 'visibilidade (extract-value 'visibilidade))
  (hash-set! evaluation-data 'compatibilidade (extract-value 'compatibilidade))
  (hash-set! evaluation-data 'controle (extract-value 'controle))
  (hash-set! evaluation-data 'consistencia (extract-value 'consistencia))
  (hash-set! evaluation-data 'prevencao_erros (extract-value 'prevencao_erros))
  (hash-set! evaluation-data 'reconhecimento (extract-value 'reconhecimento))
  (hash-set! evaluation-data 'flexibilidade (extract-value 'flexibilidade))
  (hash-set! evaluation-data 'estetica (extract-value 'estetica))
  (hash-set! evaluation-data 'recuperacao_erros (extract-value 'recuperacao_erros))
  (hash-set! evaluation-data 'ajuda_documentacao (extract-value 'recuperacao_erros))
  
  (save-evaluation evaluation-data)
  
  (redirect-to "/"))

(define (not-found-page request)
  (response/xexpr
   #:code 404
   `(html
     (head
      (title "Page Not Found"))
     (body
      (div ((class "container"))
           (h1 "404 - Page Not Found")
           (p "The page you are looking for does not exist.")
           (a ((href "/") (class "button")) "Return to Home Page"))))))