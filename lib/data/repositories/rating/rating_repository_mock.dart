import '../../models/auth/user_entity.dart';
import '../../models/rating/rating_faq_section_entity.dart';
import '../../models/rating/rating_info_entity.dart';
import 'rating_repository.dart';

/// Возвращает тестовые данные рейтинга до подключения API.
class RatingRepositoryMock implements RatingRepository {
  @override
  Future<RatingInfoEntity> loadRating(UserEntity user) async {
    return RatingInfoEntity(
      value: user.rating ?? 4.5,
      updatedAt: user.updatedAt ?? DateTime.now(),
      faqSections: const <RatingFaqSectionEntity>[
        RatingFaqSectionEntity(
          title: 'На что влияет рейтинг?',
          description:
              'Чем выше рейтинг тем больше вероятность, что вам будет назначен клинер с наивысшим рейтингом, больше доступных акций и выше постоянная скидка на уборку.',
        ),
        RatingFaqSectionEntity(
          title: 'Как повысить рейтинг?',
          description:
              'Рейтинг складывается из ряда величин. Его могут повысить частота заказа уборки, своевременность оплаты, соответствие квартиры заявленному типу уборки и прочее соблюдение пунктов указанных в договоре.',
        ),
        RatingFaqSectionEntity(
          title: 'Как понижается рейтинг?',
          description:
              'Рейтинг понижается, если вы не соблюдаете пункты договора, при задержке оплаты более 3-х дней, регулярном несоответствии типа заказанной уборки с реальными масштабами загрязнения.',
        ),
        RatingFaqSectionEntity(
          title: 'Чем опасен низкий рейтинг?',
          description:
              'При понижении рейтинга вам становятся недоступны топовые клинеры, вы перестаете попадать под акционные предложения. При сильном снижении рейтинга повышается коэффициент стоимости уборки и вы можете быть вообще отключены от системы.',
        ),
      ],
    );
  }
}
