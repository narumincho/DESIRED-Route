port module DesiredRoute exposing (Model, Msg, main)

import Html exposing (..)
import Html.Attributes exposing (id, class, src, href, alt)
import Html.Lazy exposing (lazy3)
import Svg
import Svg.Attributes as Svga


port elmLoaded : String -> Cmd msg


port receive : (Maybe Int -> msg) -> Sub msg


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type WalkState
    = Stop
    | Walking Direction Int


type Direction
    = Up
    | Left
    | Right
    | Down


type alias Model =
    { x : Int
    , y : Int
    , walkState : WalkState
    }


type Button
    = ButtonA
    | ButtonB
    | ButtonX
    | ButtonY


type Msg
    = ChangeButton (Maybe Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        dMsg : Maybe Direction
        dMsg =
            case msg of
                ChangeButton (Just 0) ->
                    Just Right

                ChangeButton (Just 2) ->
                    Just Down

                ChangeButton (Just 4) ->
                    Just Left

                ChangeButton (Just 6) ->
                    Just Up

                _ ->
                    Nothing

        move : Direction -> { a | x : Int, y : Int } -> { a | x : Int, y : Int }
        move dir rec =
            case dir of
                Right ->
                    { rec | x = rec.x + 1 }

                Down ->
                    { rec | y = rec.y + 1 }

                Left ->
                    { rec | x = rec.x - 1 }

                Up ->
                    { rec | y = rec.y - 1 }
    in
        (case model of
            { x, y, walkState } ->
                case walkState of
                    Stop ->
                        case dMsg of
                            Just x ->
                                { model | walkState = Walking x 0 }

                            Nothing ->
                                model

                    Walking dir step ->
                        if 32 <= step then
                            let
                                moved =
                                    move dir model
                            in
                                case dMsg of
                                    Just x ->
                                        { moved | walkState = Walking x 0 }

                                    Nothing ->
                                        { moved | walkState = Stop }
                        else
                            { model | walkState = Walking dir (step + 2) }
        )
            ! [ Cmd.none ]


view : Model -> Html Msg
view { x, y, walkState } =
    lazy3 lazyedView x y walkState


lazyedView : Int -> Int -> WalkState -> Html msg
lazyedView x y walkState =
    let
        baseX =
            x * 32

        baseY =
            y * 32

        stepX =
            case walkState of
                Walking Left s ->
                    -s

                Walking Right s ->
                    s

                _ ->
                    0

        stepY =
            case walkState of
                Walking Up s ->
                    -s

                Walking Down s ->
                    s

                _ ->
                    0

        viewBox : String
        viewBox =
            [ toString (baseX + stepX - 400 + 16)
            , " "
            , toString (baseY + stepY - 256 + 48)
            , " "
            , toString (32 * 25)
            , " "
            , toString (32 * 16)
            ]
                |> String.concat
    in
        div [ id "elm-root" ]
            [ Svg.svg
                [ Svga.viewBox viewBox ]
                (bg (baseX + stepX) (baseY + stepY))
            ]


bg : Int -> Int -> List (Svg.Svg msg)
bg cx cy =
    (map
        |> List.indexedMap
            (\y mapList ->
                mapList
                    |> List.indexedMap
                        (\x chip ->
                            Svg.image
                                [ Svga.xlinkHref (bgToUrl chip)
                                , Svga.height "33"
                                , Svga.width "33"
                                , Svga.x (toString (x * 32))
                                , Svga.y (toString (y * 32))
                                ]
                                []
                        )
            )
        |> List.concat
    )
        ++ [ Svg.image
                [ Svga.x (toString cx)
                , Svga.y (toString (cy - 16))
                , Svga.width "32"
                , Svga.height "48"
                , Svga.xlinkHref "image/rafya.png"
                ]
                []
           ]


type Bg
    = Stone
    | Wood
    | WoodBottom
    | WoodCorner
    | WoodCornerInv
    | Temp


type alias Url =
    String


bgToUrl : Bg -> Url
bgToUrl x =
    "image/"
        ++ case x of
            Stone ->
                "bg_stone.png"

            Wood ->
                "bg_wood.png"

            WoodBottom ->
                "bg_wood_bottom.png"

            WoodCorner ->
                "bg_wood_corner.png"

            WoodCornerInv ->
                "bg_wood_corner_inv.png"

            Temp ->
                "bg_temp.png"


charToBg : Char -> Bg
charToBg c =
    case c of
        ' ' ->
            Stone

        '1' ->
            Wood

        '0' ->
            WoodBottom

        '2' ->
            WoodCorner

        '3' ->
            WoodCornerInv

        _ ->
            Temp


stringToBgList : String -> List Bg
stringToBgList =
    String.toList >> List.map charToBg


map : List (List Bg)
map =
    mapString
        |> List.map stringToBgList


mapString : List String
mapString =
    [ "                111111 1 "
    , "   1111111111111        11"
    , "   1111111111111    ttttt"
    , "   2011111111103    ttttt"
    , "     201111103     tttttt"
    , "       20003      ttttttt"
    , "                ttttttttt"
    , "   2011111111103    ttttt"
    , "     201111103     tttttt"
    , "       20003      ttttttt"
    , "                ttttttttt"
    , "                ttttttttt"
    , "   111111111    ttttttttt"
    , "    1111111     ttttttttt"
    , "     11111      ttttttttt"
    , "   111111111    ttttttttt"
    , "    1111111     ttttttttt"
    , "     11111      ttttttttt"
    , "   111111111    ttttttttt"
    ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    receive ChangeButton


init : ( Model, Cmd Msg )
init =
    { x = 0, y = 0, walkState = Stop }
        ! [ elmLoaded "loaded" ]
