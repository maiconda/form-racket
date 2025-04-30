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
  (printf "URL path: ~a\n" (map path/param-path (url-path (request-uri request))))
  
  (with-handlers ([exn:fail? (lambda (e)
                              (printf "Dispatch error: ~a\n" (exn-message e))
                              (not-found-page))])
    (dispatch request)))

(define (page-template title content)
  `(html
    (head
     (title ,title)
     (meta ((charset "utf-8")))
     (meta ((name "viewport") (content "width=device-width, initial-scale=1")))
     (link ((rel "stylesheet") (href "https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css")))
     (script ((src "https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js")))
     (script ((src "https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js")))
     (style "html, body { height: 100%; } body { display: flex; flex-direction: column; min-height: 100vh; } .content-wrapper { flex: 1 0 auto; display: flex; flex-direction: column; } .flex-fill { flex: 1; }"))
    (body
     (nav ((class "navbar navbar-expand-lg navbar-dark bg-primary mb-0"))
          (div ((class "container"))
               (a ((class "navbar-brand") (href "/")) "Avaliação de Usabilidade")
               (button ((class "navbar-toggler") (type "button") (data-bs-toggle "collapse") (data-bs-target "#navbarNav"))
                       (span ((class "navbar-toggler-icon"))))
               (div ((class "collapse navbar-collapse") (id "navbarNav"))
                    (ul ((class "navbar-nav ms-auto"))
                        (li ((class "nav-item"))
                            (a ((class "nav-link") (href "/")) "Página inicial"))
                        (li ((class "nav-item"))
                            (a ((class "nav-link") (href "/form")) "Avaliar"))
                        (li ((class "nav-item"))
                            (a ((class "nav-link") (href "/chart")) "Resultados"))))))
     (div ((class "content-wrapper"))
          (div ((class "container py-4 flex-fill"))
               ,content))
     (footer ((class "footer py-3 bg-light"))
             (div ((class "container text-center"))
                  (span ((class "text-muted")) "Ferramenta de Avaliação de Usabilidade do DrRacket"))))))

(define (chart-page request)
  (let ([stats (get-data)])
    (response/xexpr
     (page-template
      "Resultados"
      `(div
        (h1 ((class "display-4 mb-4")) "Resultados da Avaliação de Usabilidade")
        (p ((class "lead mb-4")) "Bem-vindo à ferramenta de Avaliação de Usabilidade do DrRacket. Esta aplicação permite aos usuários avaliar o software DrRacket com base nas 10 heurísticas de usabilidade de Nielsen.")
        
        (div ((class "row"))
             (div ((class "col-md-8"))
                  (div ((class "card shadow-sm mb-4"))
                       (div ((class "card-header bg-light"))
                            (h5 ((class "card-title mb-0")) "Resultados da Avaliação"))
                       (div ((class "card-body"))
                            (canvas ((id "evaluation-chart"))))))
             
             (div ((class "col-md-4"))
                  (div ((class "card shadow-sm mb-4"))
                       (div ((class "card-header bg-light"))
                            (h5 ((class "card-title mb-0")) "Estatísticas"))
                       (div ((class "card-body"))
                            (p ((class "mb-2")) ,(format "Total de avaliações: ")
                               (span ((class "badge bg-primary")) ,(format "~a" (hash-ref stats 'quantidade))))
                            (p ((class "mb-0")) ,(format "Média geral: ")
                               (span ((class "badge bg-success")) ,(format "~a/10" 
                                              (let ([avg (/ (apply + (hash-ref stats 'medias)) 
                                                           (length (hash-ref stats 'medias)))])
                                                (number->string (/ (round (* avg 10)) 10))))))))))
        
        (div ((class "d-grid gap-2 col-6 mx-auto mt-4"))
             (a ((href "/form") (class "btn btn-primary btn-lg")) "Avaliar DrRacket"))
        
        (script
         ,(format "~a" 
                  (string-append 
                   "document.addEventListener('DOMContentLoaded', function() {
                      const ctx = document.getElementById('evaluation-chart').getContext('2d');
                      const chart = new Chart(ctx, {
                          type: 'polarArea',
                          data: {
                              labels: ['Visibilidade', 'Compatibilidade', 'Controle', 'Consistência', 
                                      'Prevenção de Erros', 'Reconhecimento', 'Flexibilidade', 'Estética', 
                                      'Recuperação de Erros', 'Ajuda e Documentação'],
                              datasets: [{
                                  label: 'Avaliação Média',
                                  data: [" (string-join (map number->string (hash-ref stats 'medias)) ", ") "],
                                  borderWidth: 1,
                                  backgroundColor: [
                                      'rgba(54, 162, 235, 0.6)',
                                      'rgba(75, 192, 192, 0.6)',
                                      'rgba(153, 102, 255, 0.6)',
                                      'rgba(255, 159, 64, 0.6)',
                                      'rgba(255, 99, 132, 0.6)',
                                      'rgba(255, 206, 86, 0.6)',
                                      'rgba(54, 162, 235, 0.6)',
                                      'rgba(75, 192, 192, 0.6)',
                                      'rgba(153, 102, 255, 0.6)',
                                      'rgba(255, 159, 64, 0.6)'
                                  ],
                                  borderColor: [
                                      'rgba(54, 162, 235, 1)',
                                      'rgba(75, 192, 192, 1)',
                                      'rgba(153, 102, 255, 1)',
                                      'rgba(255, 159, 64, 1)',
                                      'rgba(255, 99, 132, 1)',
                                      'rgba(255, 206, 86, 1)',
                                      'rgba(54, 162, 235, 1)',
                                      'rgba(75, 192, 192, 1)',
                                      'rgba(153, 102, 255, 1)',
                                      'rgba(255, 159, 64, 1)'
                                  ],
                                  borderWidth: 1
                              }]
                          },
                          options: {
                              responsive: true,
                              maintainAspectRatio: false,
                          }
                      });
                  });"))))))))

(define (home-page request)
  (let ([stats (get-data)])
    (response/xexpr
     (page-template
      "Avaliação de Usabilidade do DrRacket - Início"
      `(div ((class "text-center"))
            (h1 ((class "display-4 mb-4")) "Avaliação de Usabilidade do DrRacket")
            (p ((class "lead mb-4")) "Bem-vindo à ferramenta de Avaliação de Usabilidade do DrRacket. Esta aplicação permite aos usuários avaliar o software DrRacket com base nas 10 heurísticas de usabilidade de Nielsen.")
            
            (div ((class "card shadow-sm mb-5"))
                 (div ((class "card-body"))
                      (h2 ((class "h4 mb-3")) "Estatísticas Atuais")
                      (p ((class "mb-2")) ,(format "Total de avaliações: ")
                         (span ((class "badge bg-primary")) ,(format "~a" (hash-ref stats 'quantidade))))
                      (p ((class "mb-0")) ,(format "Média geral: ")
                         (span ((class "badge bg-success")) ,(format "~a/10" 
                                        (let ([avg (/ (apply + (hash-ref stats 'medias)) 
                                                     (length (hash-ref stats 'medias)))])
                                          (number->string (/ (round (* avg 10)) 10))))))))
            
            (div ((class "row mt-4"))
                 (div ((class "col-md-6"))
                      (div ((class "d-grid"))
                           (a ((href "/form") (class "btn btn-primary btn-lg mb-3")) "Avaliar DrRacket")))
                 (div ((class "col-md-6"))
                      (div ((class "d-grid"))
                           (a ((href "/chart") (class "btn btn-outline-primary btn-lg mb-3")) "Ver Resultados")))))))))

(define (form-page request)
  (response/xexpr
   (page-template
    "Avaliar DrRacket - Avaliação de Usabilidade"
    `(div
      (h1 ((class "display-4 mb-4")) "Avaliar DrRacket")
      (p ((class "lead mb-4")) "Por favor, avalie o DrRacket com base nas 10 heurísticas de usabilidade de Nielsen. Use os controles deslizantes para selecionar sua nota (1-10).")
      
      (form ((action "/submit") (method "post") (id "evaluation-form"))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "1. Visibilidade do status do sistema"))
                 (div ((class "card-body"))
                      (p "O sistema mantém o usuário informado sobre o que está acontecendo, de forma adequada e em tempo razoável?")
                      (div ((class "mb-3"))
                           (label ((for "visibilidade-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "visibilidade") (id "visibilidade-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "2. Compatibilidade entre o sistema e o mundo real"))
                 (div ((class "card-body"))
                      (p "O sistema utiliza linguagem, conceitos e símbolos familiares aos usuários, refletindo o modo como eles pensam?")
                      (div ((class "mb-3"))
                           (label ((for "compatibilidade-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "compatibilidade") (id "compatibilidade-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "3. Controle e liberdade do usuário"))
                 (div ((class "card-body"))
                      (p "O usuário consegue desfazer facilmente ações e se sente no controle das interações com o sistema?")
                      (div ((class "mb-3"))
                           (label ((for "controle-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "controle") (id "controle-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "4. Consistência e padrões"))
                 (div ((class "card-body"))
                      (p "O sistema mantém consistência visual e funcional? Termos, cores, botões e comportamentos seguem um padrão previsível?")
                      (div ((class "mb-3"))
                           (label ((for "consistencia-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "consistencia") (id "consistencia-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "5. Prevenção de erros"))
                 (div ((class "card-body"))
                      (p "O sistema ajuda a evitar que os usuários cometam erros, oferecendo boas validações e alertas?")
                      (div ((class "mb-3"))
                           (label ((for "prevencao_erros-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "prevencao_erros") (id "prevencao_erros-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "6. Reconhecimento em vez de memorização"))
                 (div ((class "card-body"))
                      (p "O sistema minimiza a necessidade de memorização, apresentando informações, opções e ações visíveis e acessíveis?")
                      (div ((class "mb-3"))
                           (label ((for "reconhecimento-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "reconhecimento") (id "reconhecimento-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "7. Flexibilidade e eficiência de uso"))
                 (div ((class "card-body"))
                      (p "O sistema oferece caminhos eficientes para usuários experientes, como atalhos ou automações, sem prejudicar os iniciantes?")
                      (div ((class "mb-3"))
                           (label ((for "flexibilidade-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "flexibilidade") (id "flexibilidade-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "8. Estética e design minimalista"))
                 (div ((class "card-body"))
                      (p "A interface é limpa, organizada e mostra apenas o que é necessário para a tarefa em questão?")
                      (div ((class "mb-3"))
                           (label ((for "estetica-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "estetica") (id "estetica-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "9. Ajudar os usuários a reconhecer, diagnosticar e recuperar erros"))
                 (div ((class "card-body"))
                      (p "As mensagens de erro são claras, informativas e orientam o usuário sobre como resolver o problema?")
                      (div ((class "mb-3"))
                           (label ((for "recuperacao_erros-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "recuperacao_erros") (id "recuperacao_erros-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "card shadow-sm mb-4"))
                 (div ((class "card-header bg-light"))
                      (h2 ((class "h5 mb-0")) "10. Ajuda e documentação"))
                 (div ((class "card-body"))
                      (p "Existe documentação ou ajuda acessível que realmente apoia o usuário quando necessário?")
                      (div ((class "mb-3"))
                           (label ((for "ajuda_documentacao-value") (class "form-label d-none")) "Nota")
                           (div ((class "d-flex align-items-center"))
                                (input ((type "range") (class "form-range me-2") (name "ajuda_documentacao") (id "ajuda_documentacao-value") 
                                       (value "5") (min "1") (max "10") (oninput "this.nextElementSibling.textContent = this.value")))
                                (span ((class "badge bg-primary")) "5")))))
            
            (div ((class "d-grid gap-2 col-6 mx-auto mt-4 mb-4"))
                 (button ((type "submit") (class "btn btn-success btn-lg")) "Enviar Avaliação")))))))

(define (submit-evaluation request)
  (define bindings
    (request-bindings/raw request))
  
  (define dados_avaliacao
    (make-hash))
  
  (define (extract-value field-name)
    (define field-bytes (string->bytes/utf-8 (symbol->string field-name)))
    (define binding (bindings-assq field-bytes bindings))
    (if binding
        (string->number (bytes->string/utf-8 (binding:form-value binding)))
        0))
  
  (hash-set! dados_avaliacao 'visibilidade (extract-value 'visibilidade))
  (hash-set! dados_avaliacao 'compatibilidade (extract-value 'compatibilidade))
  (hash-set! dados_avaliacao 'controle (extract-value 'controle))
  (hash-set! dados_avaliacao 'consistencia (extract-value 'consistencia))
  (hash-set! dados_avaliacao 'prevencao_erros (extract-value 'prevencao_erros))
  (hash-set! dados_avaliacao 'reconhecimento (extract-value 'reconhecimento))
  (hash-set! dados_avaliacao 'flexibilidade (extract-value 'flexibilidade))
  (hash-set! dados_avaliacao 'estetica (extract-value 'estetica))
  (hash-set! dados_avaliacao 'recuperacao_erros (extract-value 'recuperacao_erros))
  (hash-set! dados_avaliacao 'ajuda_documentacao (extract-value 'ajuda_documentacao))
  
  (save dados_avaliacao)
  
  (redirect-to "/"))

(define (not-found-page request)
  (response/xexpr
   #:code 404
   (page-template
    "Página Não Encontrada"
    `(div ((class "text-center"))
          (h1 ((class "display-4 mb-4")) "404 - Página Não Encontrada")
          (p ((class "lead mb-4")) "A página que você está procurando não existe.")
          (a ((href "/") (class "btn btn-primary")) "Voltar para a Página Inicial")))))