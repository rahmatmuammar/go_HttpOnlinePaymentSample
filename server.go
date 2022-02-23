package main

import (
	"fmt"
	"net/http"

	"./controller"
	router "./http"
	"./repository"
	"./service"
)

var (
	postRepository repository.PostRepository = repository.NewPsqlRepo()
	postService    service.PostService       = service.NewPostService(postRepository)
	postController controller.PostController = controller.NewPostController(postService)
	httpRouter     router.Router             = router.NewMuxRouter()
)

func main() {
	const port string = ":8080"

	httpRouter.GET("/", func(resp http.ResponseWriter, req *http.Request) {
		fmt.Fprintln(resp, "is Running..")
	})

	httpRouter.POST("/registration", postController.Postregistration)
	httpRouter.POST("/user_info", postController.PostgetUserInfo)
	httpRouter.POST("/login", postController.Postlogin)
	httpRouter.POST("/logout", postController.Postlogout)
	httpRouter.POST("/change_account_active_status", postController.PostchangeAccountActiveStatus)
	httpRouter.POST("/topup", postController.Posttopup)
	httpRouter.POST("/debit", postController.Posdebit)
	httpRouter.SERVE(port)

}
