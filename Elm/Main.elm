port module DesiredRoute exposing (Model, Msg, main)

import Html exposing (..)
import Html.Attributes exposing (id,class,src,href,alt)

port elmLoaded : String -> Cmd msg

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
    }


type alias Model =
    { lv : Int
    }


type Msg
    = NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)

view : Model -> Html Msg
view model =
    div [id "elm-root"]
        [ Html.img [class "dr-img", src "image/title_logo.jpg"] []
        , div [class "window"] [text "せりふ"]
        , Html.nav [class "menu"] [text "メニュー"]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : (Model, Cmd Msg)
init = 
    ({lv = 0}, elmLoaded "loaded")
