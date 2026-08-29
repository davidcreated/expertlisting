import 'author.dart';
import 'comment.dart';
import 'media_item.dart';
import 'post.dart';
import 'post_category.dart';
import 'transaction_type.dart';

class FakeFeedSeed {
  const FakeFeedSeed._();

  static const String _lekki = 'Lekki Phase 1, Lagos';
  static const String _yaba = 'Yaba, Lagos';
  static const String _ikoyi = 'Ikoyi, Lagos';
  static const String _ajah = 'Ajah, Lagos';

  static const Author felix = Author(
    id: 'user-felix',
    name: 'Felix Okon',
    username: 'felix.okon',
    avatarUrl: 'https://i.pravatar.cc/200?img=12',
  );

  static const Author felixBroker = Author(
    id: 'user-felix',
    name: 'Felix Okon',
    username: 'felix.okon',
    avatarUrl: 'https://i.pravatar.cc/200?img=12',
    role: AuthorRole.broker,
  );

  static const Author maurice = Author(
    id: 'user-maurice',
    name: 'Maurice U',
    username: 'maurice.u',
    avatarUrl: 'https://i.pravatar.cc/200?img=45',
  );

  static const Author boyd = Author(
    id: 'user-boyd',
    name: 'Boyd From',
    username: 'boyd.from',
    avatarUrl: 'https://i.pravatar.cc/200?img=33',
    role: AuthorRole.developer,
  );

  static const Author tunde = Author(
    id: 'user-tunde',
    name: 'Tunde Bakare',
    username: 'tunde_b',
    avatarUrl: 'https://i.pravatar.cc/200?img=15',
  );

  static const Author amaka = Author(
    id: 'user-amaka',
    name: 'Amaka Eze',
    username: 'amaka.eze',
    avatarUrl: 'https://i.pravatar.cc/200?img=47',
    role: AuthorRole.agent,
  );

  static const Author ramos = Author(
    id: 'user-ramos',
    name: 'RamosRealty',
    username: 'ramosrealty',
    avatarUrl: 'https://i.pravatar.cc/200?img=68',
    role: AuthorRole.developer,
  );

  static const Author jordan = Author(
    id: 'user-jordan',
    name: 'Jordan',
    username: 'jordan.a',
    avatarUrl: 'https://i.pravatar.cc/200?img=11',
  );

  static const Author taylor = Author(
    id: 'user-taylor',
    name: 'Taylor',
    username: 'taylor.w',
    avatarUrl: 'https://i.pravatar.cc/200?img=52',
  );

  static const Author jamie = Author(
    id: 'user-jamie',
    name: 'Jamie',
    username: 'jamie.k',
    avatarUrl: 'https://i.pravatar.cc/200?img=14',
  );

  static const Author chidi = Author(
    id: 'user-chidi',
    name: 'Chidi Nwosu',
    username: 'chidi.n',
    avatarUrl: 'https://i.pravatar.cc/200?img=60',
    role: AuthorRole.broker,
  );

  static const Author miracle = Author(
    id: 'user-miracle',
    name: 'Miracle Hassan',
    username: 'miracle.h',
    avatarUrl: 'https://i.pravatar.cc/200?img=49',
  );

  static const List<Author> storyAuthors = [
    ramos,
    jordan,
    taylor,
    jamie,
    amaka,
    chidi,
  ];

  static const List<Author> likePreview = [miracle, tunde, jordan];

  static const String _localProperty = 'asset://assets/images/property_card.png';

  static List<Post> posts({DateTime? now}) {
    final reference = now ?? DateTime.now();

    DateTime ago(Duration duration) => reference.subtract(duration);

    return [
      Post(
        id: 'post-1',
        author: felix,
        category: PostCategory.request,
        body:
            'Looking for a 2-bedroom apartment in Yaba or Akoka. Must have '
            'constant water and parking for one car.',
        createdAt: ago(const Duration(seconds: 20)),
        location: _lekki,
        transactionType: TransactionType.lookingToBuy,
        likeCount: 1,
        likedBy: const [miracle],
      ),
      Post(
        id: 'post-2',
        author: maurice,
        category: PostCategory.general,
        body:
            'How is everyone holding up with the flooding in Lekki this week? '
            'Stay safe out there — and let me know if anyone needs a temporary '
            'place to crash 🙏',
        createdAt: ago(const Duration(seconds: 40)),
        location: _lekki,
        likeCount: 8,
        commentCount: 8,
        viewCount: 700,
        bookmarkCount: 2,
        likedBy: likePreview,
        topComment: Comment(
          id: 'comment-2-1',
          postId: 'post-2',
          author: tunde,
          body: 'Roads around Admiralty are still bad. Thanks for checking in 🙏',
          createdAt: ago(const Duration(minutes: 12)),
        ),
      ),
      Post(
        id: 'post-3',
        author: boyd,
        category: PostCategory.property,
        body:
            'Newly serviced 3-bedroom apartment with fitted kitchen, parking '
            'for 3 cars, and 24/7 power. Inspection opens this Saturday.',
        createdAt: ago(const Duration(hours: 2)),
        location: _lekki,
        transactionType: TransactionType.forRent,
        media: const [
          MediaItem(
            id: 'media-3-1',
            url: _localProperty,
            aspectRatio: 1.05,
          ),
        ],
        likeCount: 23,
        viewCount: 1000,
        bookmarkCount: 2,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-4',
        author: felix,
        category: PostCategory.request,
        body:
            'Looking for a 2-bedroom apartment in Yaba or Akoka. Must have '
            'constant water and parking for one car. Moving in by the end of '
            'next month.',
        createdAt: ago(const Duration(hours: 22)),
        location: _yaba,
        transactionType: TransactionType.lookingToRent,
        likeCount: 1,
        likedBy: const [miracle],
      ),
      Post(
        id: 'post-5',
        author: felixBroker,
        category: PostCategory.property,
        body:
            'New 2-bedroom apartment in Yaba with constant water, parking for '
            'one car and a fitted kitchen. Inspection opens this Saturday.',
        createdAt: ago(const Duration(days: 3)),
        location: _yaba,
        transactionType: TransactionType.forSale,
        media: const [
          MediaItem(
            id: 'media-5-1',
            url:
                'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1000&q=80',
            kind: MediaKind.video,
            aspectRatio: 1.1,
          ),
        ],
        likeCount: 12,
        commentCount: 3,
        viewCount: 2400,
        bookmarkCount: 1,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-6',
        author: amaka,
        category: PostCategory.property,
        body:
            'Just listed: 4-bedroom semi-detached duplex in Ikoyi. BQ, elevator '
            'access and a shared pool. Serious enquiries only.',
        createdAt: ago(const Duration(days: 4)),
        location: _ikoyi,
        transactionType: TransactionType.forSale,
        media: const [
          MediaItem(
            id: 'media-6-1',
            url:
                'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1000&q=80',
            aspectRatio: 1.2,
          ),
        ],
        likeCount: 41,
        commentCount: 6,
        viewCount: 5200,
        bookmarkCount: 9,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-7',
        author: chidi,
        category: PostCategory.request,
        body:
            'Client needs a mini flat around Ajah, budget is 1.2m annually. '
            'Water and light must be steady. Who has something?',
        createdAt: ago(const Duration(days: 5)),
        location: _ajah,
        transactionType: TransactionType.lookingToRent,
        likeCount: 4,
        commentCount: 2,
        viewCount: 320,
        likedBy: const [tunde, jordan],
      ),
      Post(
        id: 'post-8',
        author: ramos,
        category: PostCategory.property,
        body:
            'Off-plan units now open at our Ajah development. 2 and 3 bedroom '
            'flats, flexible payment over 18 months.',
        createdAt: ago(const Duration(days: 6)),
        location: _ajah,
        transactionType: TransactionType.forSale,
        media: const [
          MediaItem(
            id: 'media-8-1',
            url:
                'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1000&q=80',
            aspectRatio: 1.15,
          ),
        ],
        likeCount: 67,
        commentCount: 11,
        viewCount: 12400,
        bookmarkCount: 23,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-9',
        author: maurice,
        category: PostCategory.general,
        body:
            'Reminder for anyone renting this season: always confirm the '
            'agent is registered before you pay an inspection fee.',
        createdAt: ago(const Duration(days: 7)),
        likeCount: 89,
        commentCount: 14,
        viewCount: 8900,
        bookmarkCount: 31,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-10',
        author: jordan,
        category: PostCategory.request,
        body:
            'Looking to buy land in Ibeju-Lekki with a clean title. '
            'Governor consent preferred, budget up to 25m.',
        createdAt: ago(const Duration(days: 9)),
        location: 'Ibeju-Lekki, Lagos',
        transactionType: TransactionType.lookingToBuy,
        likeCount: 6,
        commentCount: 4,
        viewCount: 640,
        likedBy: const [tunde, amaka],
      ),
      Post(
        id: 'post-11',
        author: taylor,
        category: PostCategory.property,
        body:
            'Short-let studio in Victoria Island available from next week. '
            'Fully furnished, 24/7 power, secure estate.',
        createdAt: ago(const Duration(days: 11)),
        location: 'Victoria Island, Lagos',
        transactionType: TransactionType.forRent,
        media: const [
          MediaItem(
            id: 'media-11-1',
            url:
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1000&q=80',
            aspectRatio: 1.3,
          ),
        ],
        likeCount: 18,
        commentCount: 5,
        viewCount: 2100,
        bookmarkCount: 4,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-12',
        author: amaka,
        category: PostCategory.general,
        body:
            'Market note: rents around Lekki Phase 1 have moved about 15% '
            'since January. Plan renewals early.',
        createdAt: ago(const Duration(days: 13)),
        location: _lekki,
        likeCount: 52,
        commentCount: 9,
        viewCount: 6700,
        bookmarkCount: 17,
        likedBy: likePreview,
      ),
      Post(
        id: 'post-13',
        author: jamie,
        category: PostCategory.request,
        body:
            'Anyone with a 3-bedroom in Surulere for a family relocating from '
            'Abuja? Needed by month end.',
        createdAt: ago(const Duration(days: 15)),
        location: 'Surulere, Lagos',
        transactionType: TransactionType.lookingToRent,
        likeCount: 3,
        commentCount: 1,
        viewCount: 280,
        likedBy: const [jordan],
      ),
      Post(
        id: 'post-14',
        author: boyd,
        category: PostCategory.property,
        body:
            'Terrace units in Ikoyi, ready for occupancy. Fitted wardrobes, '
            'ample parking, dedicated transformer.',
        createdAt: ago(const Duration(days: 18)),
        location: _ikoyi,
        transactionType: TransactionType.forRent,
        media: const [
          MediaItem(
            id: 'media-14-1',
            url:
                'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1000&q=80',
            aspectRatio: 1.25,
          ),
        ],
        likeCount: 34,
        commentCount: 7,
        viewCount: 4300,
        bookmarkCount: 11,
        likedBy: likePreview,
      ),
    ];
  }

  static Map<String, List<Comment>> comments({DateTime? now}) {
    final reference = now ?? DateTime.now();

    DateTime ago(Duration duration) => reference.subtract(duration);

    return {
      'post-2': [
        Comment(
          id: 'comment-2-1',
          postId: 'post-2',
          author: tunde,
          body: 'Roads around Admiralty are still bad. Thanks for checking in 🙏',
          createdAt: ago(const Duration(minutes: 12)),
        ),
        Comment(
          id: 'comment-2-2',
          postId: 'post-2',
          author: amaka,
          body: 'We have two spare rooms in Ikate if anyone is stuck tonight.',
          createdAt: ago(const Duration(minutes: 26)),
        ),
        Comment(
          id: 'comment-2-3',
          postId: 'post-2',
          author: jordan,
          body: 'Water finally went down on my street this morning.',
          createdAt: ago(const Duration(minutes: 41)),
        ),
        Comment(
          id: 'comment-2-4',
          postId: 'post-2',
          author: chidi,
          body: 'Avoid the Admiralty Way stretch, still waist deep.',
          createdAt: ago(const Duration(hours: 1)),
        ),
        Comment(
          id: 'comment-2-5',
          postId: 'post-2',
          author: taylor,
          body: 'Sharing this with my estate group, thank you.',
          createdAt: ago(const Duration(hours: 2)),
        ),
        Comment(
          id: 'comment-2-6',
          postId: 'post-2',
          author: jamie,
          body: 'Stay safe everyone.',
          createdAt: ago(const Duration(hours: 3)),
        ),
        Comment(
          id: 'comment-2-7',
          postId: 'post-2',
          author: ramos,
          body: 'Our Lekki site is closed today for safety.',
          createdAt: ago(const Duration(hours: 4)),
        ),
        Comment(
          id: 'comment-2-8',
          postId: 'post-2',
          author: felix,
          body: 'Appreciate the update.',
          createdAt: ago(const Duration(hours: 5)),
        ),
      ],
      'post-5': [
        Comment(
          id: 'comment-5-1',
          postId: 'post-5',
          author: amaka,
          body: 'Is the price negotiable?',
          createdAt: ago(const Duration(days: 2)),
        ),
        Comment(
          id: 'comment-5-2',
          postId: 'post-5',
          author: jordan,
          body: 'Sent you a DM about inspection.',
          createdAt: ago(const Duration(days: 2, hours: 4)),
        ),
        Comment(
          id: 'comment-5-3',
          postId: 'post-5',
          author: tunde,
          body: 'Does it come with a BQ?',
          createdAt: ago(const Duration(days: 2, hours: 9)),
        ),
      ],
      'post-6': [
        Comment(
          id: 'comment-6-1',
          postId: 'post-6',
          author: chidi,
          body: 'I have a client for this. Calling you now.',
          createdAt: ago(const Duration(days: 3)),
        ),
        Comment(
          id: 'comment-6-2',
          postId: 'post-6',
          author: boyd,
          body: 'Clean finish. Well done.',
          createdAt: ago(const Duration(days: 3, hours: 6)),
        ),
        Comment(
          id: 'comment-6-3',
          postId: 'post-6',
          author: taylor,
          body: 'What is the service charge like?',
          createdAt: ago(const Duration(days: 3, hours: 11)),
        ),
        Comment(
          id: 'comment-6-4',
          postId: 'post-6',
          author: jamie,
          body: 'Is the pool shared with the next block?',
          createdAt: ago(const Duration(days: 3, hours: 15)),
        ),
        Comment(
          id: 'comment-6-5',
          postId: 'post-6',
          author: felix,
          body: 'Beautiful property.',
          createdAt: ago(const Duration(days: 3, hours: 20)),
        ),
        Comment(
          id: 'comment-6-6',
          postId: 'post-6',
          author: maurice,
          body: 'Ikoyi prices are wild these days.',
          createdAt: ago(const Duration(days: 4)),
        ),
      ],
      'post-7': [
        Comment(
          id: 'comment-7-1',
          postId: 'post-7',
          author: taylor,
          body: 'I have a mini flat in Badore, slightly above that budget.',
          createdAt: ago(const Duration(days: 4)),
        ),
        Comment(
          id: 'comment-7-2',
          postId: 'post-7',
          author: amaka,
          body: 'Sending you two options now.',
          createdAt: ago(const Duration(days: 4, hours: 8)),
        ),
      ],
    };
  }
}
